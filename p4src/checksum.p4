#include "headers.p4"
#include "int_headers.p4"

control MyVerifyChecksum(inout headers hdr, inout local_metadata_t local_metadata) {
    apply {  }
}

control MyComputeChecksum(inout headers hdr, inout local_metadata_t local_metadata){
    apply{//no checksum at ipv6 header
        /*
        update_checksum(hdr.report_ipv6.isValid(),
            { 
              hdr.report_ipv6.version,
              hdr.report_ipv6.dscp,
              hdr.report_ipv6.ecn,
              hdr.report_ipv6.flow_label,
              hdr.report_ipv6.payload_len,
              hdr.report_ipv6.next_header,
              hdr.report_ipv6.hop_limit,
              hdr.report_ipv6.src_addr,
              hdr.report_ipv6.dst_addr},
            hdr.report_ipv6.hdr_checksum,
            HashAlgorithm.csum16
        );
*/

        // #ifdef __INT_HEADERS__
        // update_checksum(hdr.report_ipv4.isValid(),
        //     {
        //         hdr.report_ipv4.version,
        //         hdr.report_ipv4.ihl,
        //         hdr.report_ipv4.dscp,
        //         hdr.report_ipv4.ecn,
        //         hdr.report_ipv4.len,
        //         hdr.report_ipv4.identification,
        //         hdr.report_ipv4.flags,
        //         hdr.report_ipv4.frag_offset,
        //         hdr.report_ipv4.ttl,
        //         hdr.report_ipv4.protocol,
        //         hdr.report_ipv4.src_addr,
        //         hdr.report_ipv4.dst_addr
        //     },
        //     hdr.report_ipv4.hdr_checksum,
        //     HashAlgorithm.csum16
        // );
        // #endif // __INT_HEADERS__
    }
}