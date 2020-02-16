# Usage :
# inherit  recipe-buildinfo
#
python do_check_source() {
    if not os.path.exists(d.getVar('S')):
        bb.note('gaoqiang need unpack')
        src_uri = (d.getVar('SRC_URI') or "").split()
        if len(src_uri) == 0:
            return

        try:
            fetcher = bb.fetch2.Fetch(src_uri, d)
            fetcher.unpack(d.getVar('WORKDIR'))
        except bb.fetch2.BBFetchException as e:
            bb.fatal(str(e))
        bb.note('gaoqiang unpack to: %s' % d.getVar('S'))
    else:
        bb.note('gaoqiang don\'t need unpack')
}

do_check_source[nostamp] = '1'
addtask do_check_source before do_build after do_fetch
