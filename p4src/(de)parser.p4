/*************************************************************************
*********************** P A R S E R  *******************************
*************************************************************************/

parser MyParser(packet_in packet,
                    out headers hdr,
                    inout local_metadata_t local_metadata,
                    inout standard_metadata_t standard_metadata) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            TYPE_ARP: parse_arp;
            ETH_TYPE_IPV6 : parse_ipv6;
            default : accept;
        }
    }
   
    state parse_arp {
        packet.extract(hdr.arp);
        transition select(hdr.arp.op_code) {
            ARP_REQ: accept;
            default: accept;
      }
    }

    state parse_ipv6 {
        packet.extract(hdr.ipv6);
        transition select(hdr.ipv6.next_header) {
            IP_PROTO_TCP : parse_tcp;
            IP_PROTO_UDP : parse_udp;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        local_metadata.l4_src_port = hdr.tcp.src_port;
        local_metadata.l4_dst_port = hdr.tcp.dst_port;
        transition select(hdr.ipv6.dscp) {
            DSCP_INT &&& DSCP_MASK: parse_intl4_shim;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        local_metadata.l4_src_port = hdr.udp.src_port;
        local_metadata.l4_dst_port = hdr.udp.dst_port;
        transition select(hdr.ipv6.dscp) {
            DSCP_INT &&& DSCP_MASK: parse_intl4_shim;
            default: accept;
        }
    }

    state parse_intl4_shim {
        packet.extract(hdr.intl4_shim);
        local_metadata.int_meta.intl4_shim_len = hdr.intl4_shim.len;
        transition parse_int_header;
    }

    state parse_int_header {
        packet.extract(hdr.int_header);
        transition parse_int_data;
    }

    state parse_int_data {
        // Parse INT metadata stack
        packet.extract(hdr.int_data, ((bit<32>) (local_metadata.int_meta.intl4_shim_len - INT_HEADER_WORD)) << 5);
        transition accept;
    }
}

control MyDeparser(packet_out packet, in headers hdr) {
    apply {           
        // report headers
        packet.emit(hdr.report_ethernet);
        packet.emit(hdr.report_ipv6);
        packet.emit(hdr.report_udp);
        packet.emit(hdr.report_group_header);
        packet.emit(hdr.report_individual_header);

        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv6);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);

        // int header
        packet.emit(hdr.intl4_shim);        //extra int data
        packet.emit(hdr.int_header);        //the instructions
        // hop metadata                     //the generated INT statistics at the current hop
        packet.emit(hdr.int_switch_id);
        packet.emit(hdr.int_level1_port_ids);
        packet.emit(hdr.int_hop_latency);
        packet.emit(hdr.int_q_occupancy);
        packet.emit(hdr.int_ingress_tstamp);
        packet.emit(hdr.int_egress_tstamp);
        packet.emit(hdr.int_level2_port_ids);
        packet.emit(hdr.int_egress_tx_util);

        // int data
        packet.emit(hdr.int_data);          //the generated INT statistics from the previous hops

    }
}
