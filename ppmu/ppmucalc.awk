# by qiang1.gao(20210623)
# input:  seq_id: SEQUENCE
# output: cpu,gpu,dpu mfc bw peak latency and average latency
# excel row type
#  1      2        3           4    5     6     7       8      9      10     11     12     13
# seq_no ip_index define_event time ccnt pmcnt0 pmcnt1 pmcnt2 pmcnt3 pmcnt4 pmcnt5 pmcnt6 pmcnt7
#
# From http://edm2.sec.samsung.net/cc/#/compact/verLink/161942416226504360/1
# R.BW = pmcnt0 * 16000 / (IF(time, time, 1)
# W.BW = pmcnt4 * 16000 / (IF(time, time, 1)
#
# From http://edm2.sec.samsung.net/cc/#/compact/verLink/157956471177104720/1
# Peak Latency    = max (pmcnt2,pmcnt6)
# Average Latency = max (IF(pmcnt1, quotient(pmcnt3, pmcnt1),0), IF(pmcnt5, quotient(pmcnt7, pmcnt5),0))

BEGIN {
    max_band_width=68244
    # input: SEQUENCE
    #print "use seq id:", SEQUENCE;
    # how many sample do you prefer, be careful the Rewind of csv file
    sample = 10;
    # get max BW sequcen number from ( SEQUENCE-(sample-1) ) to SEQUENCE
    seq_no_start=SEQUENCE - (sample - 1);
    seq_no_end=SEQUENCE;
    seq_no_prev=0;
    # This is the sequence number of the max BW sample
    max_seq_no=0;

    # CPU information, ip index: (1,2,3,4)
    cpu_read_band=0; cpu_write_band=0; tmp_cpu_read_band=0; tmp_cpu_write_band=0;
    # GPU information, ip index: (24,25,26,27,28,29)
    gpu_read_band=0; gpu_write_band=0; tmp_gpu_read_band=0; tmp_gpu_write_band=0;
    # DPU information, ip index: (5 ~ 16)
    dpu_read_band=0; dpu_write_band=0; tmp_dpu_read_band=0; tmp_dpu_write_band=0;
    # MFC information, ip index: (30,31,32)
    mfc_read_band=0; mfc_write_band=0; tmp_mfc_read_band=0; tmp_mfc_write_band=0;
    # ISP information, ip index: (39,40,41,42)
    isp_read_band=0; isp_write_band=0; tmp_isp_read_band=0; tmp_isp_write_band=0;

    # count cannot be bigger than 100,000
    cpu_latency_max=0; tmp_cpu_latency_max=0; cpu_latency_min=0; tmp_cpu_latency_min=100000;
    gpu_latency_max=0; tmp_gpu_latency_max=0; gpu_latency_min=0; tmp_gpu_latency_min=100000;
    dpu_latency_max=0; tmp_dpu_latency_max=0; dpu_latency_min=0; tmp_dpu_latency_min=100000;
    mfc_latency_max=0; tmp_mfc_latency_max=0; mfc_latency_min=0; tmp_mfc_latency_min=100000;
    isp_latency_max=0; tmp_isp_latency_max=0; isp_latency_min=0; tmp_isp_latency_min=100000;
    cpu_latency_average=0; tmp_cpu_latency_average=0;
    gpu_latency_average=0; tmp_gpu_latency_average=0;
    dpu_latency_average=0; tmp_dpu_latency_average=0;
    mfc_latency_average=0; tmp_mfc_latency_average=0;
    ssp_latency_average=0; tmp_isp_latency_average=0;

    # max read/write bandwith
    max_band_read=0; tmp_band_read=0; max_band_write=0; tmp_band_write=0;

    # for debug
    debug=0;
    first_in=1;
    seq_no_count=0;
}
{
    if ($1 >= seq_no_start  && $1 <= seq_no_end) {
        # we only get the sequence number which from seq_no_start to seq_no_end
        if (seq_no_prev != $1) {
            # This means a new sequence number has come, and the old sequence has finished;
            # So we need to compare the old sequence number
            if ((max_band_read + max_band_write) < (tmp_band_read + tmp_band_write)){
                # here we found the max bandwidth sequence no; and update
                max_seq_no          = seq_no_prev;
                max_band_read       = tmp_band_read;        max_band_write   = tmp_band_write;
                cpu_read_band       = tmp_cpu_read_band;    cpu_write_band   = tmp_cpu_write_band;
                gpu_read_band       = tmp_gpu_read_band;    gpu_write_band   = tmp_gpu_write_band;
                dpu_read_band       = tmp_dpu_read_band;    dpu_write_band   = tmp_dpu_write_band;
                mfc_read_band       = tmp_mfc_read_band;    mfc_write_band   = tmp_mfc_write_band;
                isp_read_band       = tmp_isp_read_band;    isp_write_band   = tmp_isp_write_band;
                cpu_latency_max     = tmp_cpu_latency_max;  cpu_latency_min  = tmp_cpu_latency_min;
                gpu_latency_max     = tmp_gpu_latency_max;  gpu_latency_min  = tmp_gpu_latency_min;
                dpu_latency_max     = tmp_dpu_latency_max;  dpu_latency_min  = tmp_dpu_latency_min;
                mfc_latency_max     = tmp_mfc_latency_max;  mfc_latency_min  = tmp_mfc_latency_min;
                isp_latency_max     = tmp_isp_latency_max;  isp_latency_min  = tmp_isp_latency_min;
                cpu_latency_average = tmp_cpu_latency_average;
                gpu_latency_average = tmp_gpu_latency_average;
                dpu_latency_average = tmp_dpu_latency_average;
                mfc_latency_average = tmp_mfc_latency_average;
                isp_latency_average = tmp_isp_latency_average;
            }

            if (debug == 1) {
                # for debug
                if (first_in != 1) {
                    printf "current SN:%d, BW:%-10.2f ", seq_no_prev, tmp_band_read + tmp_band_write;
                    printf "max SN:%d, BW:%0.2f\n", max_seq_no, max_band_read + max_band_write;
                }
                if (first_in == 1) {
                    first_in = 0
                }
            }
            seq_no_prev = $1
            seq_no_count++

            # reset
            tmp_band_read           = 0;     tmp_band_write       = 0;
            tmp_latency_peak        = 0;     tmp_latency_average  = 0;
            tmp_cpu_read_band       = 0;     tmp_cpu_write_band   = 0;
            tmp_gpu_read_band       = 0;     tmp_gpu_write_band   = 0;
            tmp_dpu_read_band       = 0;     tmp_dpu_write_band   = 0;
            tmp_mfc_read_band       = 0;     tmp_mfc_write_band   = 0;
            tmp_isp_read_band       = 0;     tmp_isp_write_band   = 0;
            tmp_cpu_latency_max     = 0;     tmp_cpu_latency_min  = 100000;
            tmp_gpu_latency_max     = 0;     tmp_gpu_latency_min  = 100000;
            tmp_dpu_latency_max     = 0;     tmp_dpu_latency_min  = 100000;
            tmp_mfc_latency_max     = 0;     tmp_mfc_latency_min  = 100000;
            tmp_isp_latency_max     = 0;     tmp_isp_latency_min  = 100000;
            tmp_cpu_latency_average = 0;
            tmp_gpu_latency_average = 0;
            tmp_dpu_latency_average = 0;
            tmp_mfc_latency_average = 0;
            tmp_isp_latency_average = 0;
         }

         ip_idx = $2;  time = $4;    ccnt = $5;
         pmcnt0 = $6;  pmcnt1 = $7;  pmcnt2 = $8;  pmcnt3 = $9;
         pmcnt4 = $10; pmcnt5 = $11; pmcnt6 = $12; pmcnt7 = $13;

         if (time == 0) {
             time = 1;
         }
         if (ccnt == 0) { ccnt = 1; }

         tmp_read_band  = pmcnt0 * 16000 / time;
         tmp_write_band = pmcnt4 * 16000  / time;

         # peak latency
         tmp_latency_peak = pmcnt2 > pmcnt6 ? pmcnt2: pmcnt6;

         # Average latency
         compare1 = pmcnt1 ? (pmcnt3/pmcnt1) : 0;
         compare2 = pmcnt5 ? (pmcnt7/pmcnt5) : 0;
         tmp_latency_average = compare1 > compare2 ? compare1 : compare2;

         #  CPU case
         if (ip_idx >= 1 && ip_idx <=  4) {
             tmp_cpu_read_band       += tmp_read_band;
             tmp_cpu_write_band      += tmp_write_band;
             tmp_band_read           += tmp_read_band;
             tmp_band_write          += tmp_write_band;
             tmp_cpu_latency_max     =  tmp_cpu_latency_max > tmp_latency_peak ? tmp_cpu_latency_max : tmp_latency_peak;
             tmp_cpu_latency_min     =  tmp_cpu_latency_min < tmp_latency_peak ? tmp_cpu_latency_min : tmp_latency_peak;

             tmp_cpu_latency_average += tmp_latency_average;

         }
         # GPU case
         if (ip_idx >= 24 && ip_idx <= 29 ) {
             tmp_gpu_read_band       += tmp_read_band;
             tmp_gpu_write_band      += tmp_write_band;
             tmp_band_read           += tmp_read_band;
             tmp_band_write          += tmp_write_band;
             tmp_gpu_latency_max     =  tmp_gpu_latency_max > tmp_latency_peak ? tmp_gpu_latency_max : tmp_latency_peak;
             tmp_gpu_latency_min     =  tmp_gpu_latency_min < tmp_latency_peak ? tmp_gpu_latency_min : tmp_latency_peak;
             tmp_gpu_latency_average += tmp_latency_average;
         }
         # DPU
         if (ip_idx >= 5 && ip_idx <= 16 ) {
             tmp_dpu_read_band       += tmp_read_band;
             tmp_dpu_write_band      += tmp_write_band;
             tmp_band_read           += tmp_read_band;
             tmp_band_write          += tmp_write_band;
             tmp_dpu_latency_max     =  tmp_dpu_latency_max > tmp_latency_peak ? tmp_dpu_latency_max : tmp_latency_peak;
             tmp_dpu_latency_min     =  tmp_dpu_latency_min < tmp_latency_peak ? tmp_dpu_latency_min : tmp_latency_peak;
             tmp_dpu_latency_average += tmp_latency_average;
         }
         # MFC
         if (ip_idx >= 30 && ip_idx <= 32 ) {
             tmp_mfc_read_band       += tmp_read_band;
             tmp_mfc_write_band      += tmp_write_band;
             tmp_band_read           += tmp_read_band;
             tmp_band_write          += tmp_write_band;
             tmp_mfc_latency_max     =  tmp_mfc_latency_max > tmp_latency_peak ? tmp_mfc_latency_max : tmp_latency_peak;
             tmp_mfc_latency_min     =  tmp_mfc_latency_min < tmp_latency_peak ? tmp_mfc_latency_min : tmp_latency_peak;
             tmp_mfc_latency_average += tmp_latency_average;
         }

         # ISP
         if (ip_idx >= 39 && ip_idx <= 42 ) {
             tmp_isp_read_band       += tmp_read_band;
             tmp_isp_write_band      += tmp_write_band;
             tmp_band_read           += tmp_read_band;
             tmp_band_write          += tmp_write_band;
             tmp_isp_latency_max     =  tmp_isp_latency_max > tmp_latency_peak ? tmp_isp_latency_max : tmp_latency_peak;
             tmp_isp_latency_min     =  tmp_isp_latency_min < tmp_latency_peak ? tmp_isp_latency_min : tmp_latency_peak;
             tmp_isp_latency_average += tmp_latency_average;
         }
    }
}
END {
    # handle the last sample
    if ((max_band_read + max_band_write) < (tmp_band_read + tmp_band_write)){
        # here we found the max bandwidth sequence no; and update
        max_seq_no          = seq_no_prev;
        max_band_read       = tmp_band_read;        max_band_write  = tmp_band_write;
        cpu_read_band       = tmp_cpu_read_band;    cpu_write_band  = tmp_cpu_write_band;
        gpu_read_band       = tmp_gpu_read_band;    gpu_write_band  = tmp_gpu_write_band;
        dpu_read_band       = tmp_dpu_read_band;    dpu_write_band  = tmp_dpu_write_band;
        mfc_read_band       = tmp_mfc_read_band;    mfc_write_band  = tmp_mfc_write_band;
        isp_read_band       = tmp_isp_read_band;    isp_write_band  = tmp_isp_write_band;
        cpu_latency_max     = tmp_cpu_latency_max;  cpu_latency_min  = tmp_cpu_latency_min;
        gpu_latency_max     = tmp_gpu_latency_max;  gpu_latency_min  = tmp_gpu_latency_min;
        dpu_latency_max     = tmp_dpu_latency_max;  dpu_latency_min  = tmp_dpu_latency_min;
        mfc_latency_max     = tmp_mfc_latency_max;  mfc_latency_min  = tmp_mfc_latency_min;
        isp_latency_max     = tmp_isp_latency_max;  isp_latency_min  = tmp_isp_latency_min;
        cpu_latency_average = tmp_cpu_latency_average;
        gpu_latency_average = tmp_gpu_latency_average;
        dpu_latency_average = tmp_dpu_latency_average;
        mfc_latency_average = tmp_mfc_latency_average;
        isp_latency_average = tmp_isp_latency_average;
    }

    # for debug
    if (debug == 1) {
        printf "current SN:%d, BW:%-10.2f ", seq_no_prev, tmp_band_read + tmp_band_write;
        printf "max SN:%d, BW:%0.2f\n", max_seq_no, max_band_read + max_band_write;
    }
    tmp_band_read  = 0
    tmp_band_write = 0

    # end, now output the max
    printf "cpu %0.2f %0.2f %d %d %d\n", cpu_read_band, cpu_write_band, cpu_latency_max, cpu_latency_min, cpu_latency_average;
    printf "gpu %0.2f %0.2f %d %d %d\n", gpu_read_band, gpu_write_band, gpu_latency_max, gpu_latency_min, gpu_latency_average;
    printf "dpu %0.2f %0.2f %d %d %d\n", dpu_read_band, dpu_write_band, dpu_latency_max, dpu_latency_min, dpu_latency_average;
    printf "mfc %0.2f %0.2f %d %d %d\n", mfc_read_band, mfc_write_band, mfc_latency_max, mfc_latency_min, mfc_latency_average;
    printf "isp %0.2f %0.2f %d %d %d\n", isp_read_band, isp_write_band, isp_latency_max, isp_latency_min, isp_latency_average;
    printf "tot %0.2f %0.2f %0.2f\n",    max_band_read, max_band_write, max_band_read+max_band_write;
}
