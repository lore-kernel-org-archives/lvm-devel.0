From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 11 Feb 2020 05:02:08 -0500
Subject: v2_03_08 annotated tag has been created
Message-ID: <45553.120021105020300119@us-mta-337.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=490690356ce890f2d90fea3b7f69475ee4ea5296
Commit:        490690356ce890f2d90fea3b7f69475ee4ea5296
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2020-02-11 09:53 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2020-02-11 09:53 +0000

annotated tag: v2_03_08 has been created
	    at 490690356ce890f2d90fea3b7f69475ee4ea5296 (tag)
       tagging b9752d719ce533c10eff9e6dbad560da33f50b65 (commit)
      replaces v2_03_07

Release 2.03.08

- IMPORTANT: Prohibit reshape of stacked raid LVs to prevent corruption.
- Improved handling of writecache and VDO volumes.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJeQnrMAAoJELkRJDHlCQOfzpkP/3lsfoRQRTG0hGoa1ZMzazG+
ahz60PvSIjmKfdRvROpPL0xjJ9Uk4WZ3m4UDglkwg874jQ69snO3Enys+xhFcCNV
cmuYlXybRfsjQ0O1jg6K0dfppNXdNwWbmi1ZuiOEXaWeNenvS2wgz3nczxFlLHUA
Ay/xRyP15egnlPjoMsFfoBCuIITB7MmIbdFppPWP7fsLjonHIE6eQKWdDTu3zWgg
i/KmCYIjIpdWZH8hCwW7n5Qw6odKbUMV8eo81szTEuLK2JoRGG+2g018Kc+hutLQ
45grMHdUUi5dQ8JUQwlHgC4xPksIwpzHYkeXuH+MsvW/LzWRK8Pic9G3Gpyzv7LX
yJAPd1V6N/oYBWk1LwV4p2ZmBzL61vmC6QKgYqMLrq/6FpqJNNFjToCRo7R+BqHQ
PC2Xvj05DdB17sPhmmSyPnuyMZlae56HRGbeide4FXeAN3BkFg+eSzn9jo855FZm
7Elt/lbbao6hz5gLjqjL7F+gHS72W1tFOLRVoFEOjz13LkYTODSl1ojH6zIcE/hM
6GAKDFf1tBp8fxC4FOSQQM5slHmkx5IuRaDftw27swhjDlGGluCplrw9646Vuo2I
ErLZb9sOF3mwvT80M0cwidOOcoJ23jm1O//RDh60LS4aY+iw32/5Yozj5jA2DchH
yoUpObU7KyiYP2gchPZn
=cNyC
-----END PGP SIGNATURE-----

David Teigland (19):
      pvck: deal with coverity warnings
      update option description for settings
      man pvck: describe settings
      pvck: show specific dump option values
      drop warnings about missing pvs in foreign vgs
      man: pvck dump description improvements
      lvmlockd: use ret value in query function
      man: updates to lvmcache
      writecache: report status fields
      man: lvmcache writecache watermark percent
      writecache: reject invalid high/low watermark setting
      vgsplit: handle cachevol
      pvmove: prevent moving writecache device
      tests: move vgsplit writecache
      writecache: fix splitcache when origin is raid
      writecache: prevent snapshots
      writecache: fix return value
      writecache: check for invalid cachevol
      writecache: skip zeroing in test mode

Heming Zhao (2):
      fix corosync.conf: no interface error
      add suggestion message for mirror LVs

Marian Csontos (4):
      post-release
      tests: VDO detection in dbus tests
      tests: Some lvmdbus tests require larger PVs
      pre-release

Nikhil Kshirsagar (1):
      debug: print VG name in log messages for segment errors

Tony Asleson (1):
      WHATS_NEW: VDO lvmdbusd adds

Vojtech Trefny (2):
      lvmdbusd: Add VDO enable/disable compress & dedup
      lvmdbusd: Add function to convert LV into a VDO pool

Zdenek Kabelac (38):
      libdm: support device RELOAD with maj:min and devname set
      libdm: set maj:min while creating and reloading device
      debug: avoid to slashes in debug message
      debug: enhance messages
      vg_read: use else for 3 case
      clenaup: simpler form
      test: aux setup
      test: fail on device create
      test: fix missing waiting on udev
      tests: improve secure test
      raid: disallow reshape of stacked LVs
      vdo: avoid running initialization of cache pool vars
      tests: update for readahead
      WHATS_NEW: update
      raid: more limitted prohibition of stacked raid usage
      vdo: adapt for multi line vdo_format output
      tests: writeerror_dev
      tests: add corruption write on PV test
      WHATS_NEW: update
      tests: compatible with older kernels
      dmsetup: no memleak on failed realocation
      pvck: avoid memleak of vgname
      bcache: fix memleak on error path
      cov: unused header file removal
      cov: widen before calculating min_chunk_size
      cov: check error code from mutex init
      lvmlockd: move eval of ENOENT
      lvmlockctl: ensure result value is always defined
      lvmlockctl: use inline initilizers
      dmeventd: nicer error path for reading pipe
      command: validate reporting of previous argument
      lv_manip: add error handling for _reserve_area
      raid: add internal error for no segment
      lv_manip: add extra check for existin origin_lv
      generate: remake
      WHATS_NEW: update
      raid: better place for blocking reshapes
      vdo: fix vdoformat when -V is specified



