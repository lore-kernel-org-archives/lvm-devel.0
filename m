From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 23 Nov 2018 03:19:47 -0500
Subject: v2_02_76 annotated tag has been created
Message-ID: <201811230819.wAN8JlAJ032121@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04c0ec626ec9eff915057829169c5b0c16eb5388
Commit:        04c0ec626ec9eff915057829169c5b0c16eb5388
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-11-22 16:48 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-11-22 16:48 +0000

annotated tag: v2_02_76 has been created
	    at 04c0ec626ec9eff915057829169c5b0c16eb5388 (tag)
       tagging ab3b542a188c9dcf1a170b33f5077bcfd1744098 (commit)
      replaces v2_02_74

Release 2.02.76
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb9t3uAAoJELkRJDHlCQOff8MQAOZ5gCw2dyTDcE85GwgKmDMP
tAudeZynRCF4Mrr4sF9egFKIPKd2OLE4PJntmW/5eCZo78WsbJJl+McHCojtkBc+
e2wFTpvgIAyXiKsQbXnAPlmgSn4boZn6Epf1tql6nR7F6GKBJemcDrLz3eIruQDy
zWnsBkpI2O4ngF0aV//Tx0O6j8b4hVTEH9G/Otk5BVprf35fTE53uORqWR9RgtHu
/HMx/jt6twlX96GfEEdy9gISpT88ZF6XGWTzFBB6TSQWjogG/1Iaz+9YtqdAH7qW
qQ2EE/0eMGJxS+1SrFCUrU02GgZZV6op28Wx/yPfnHZfyyM4NeLxnw9dIc79WZxu
gRuzAIdmyztc+r2+/202To20eoxzaqaskEnijf1h0jveqrtZ+IABhSwkUqoX/qif
FluBRbEiJHZBuX5lq47pAINJS81zTVTifsptSvVUQ7jF5qABaUpxaWCXQxWWOkEq
WPamnZG5rY4GHo7k1xBfDk+HghbGX5WWPVQVZV/XyzN8T/xNglz2Y1v/67XP9jKt
IdD5Gq15fOITIeMI9OXQWLNyNoPuZ6CGkHg51EOJuZrJtbUfOPwgwkF5I+kj83jc
L8IVYsWXOQtXBlfFb42D12nvRd6K+dQvHQQmPXFoahWXvSMI6RD9LLEFBVHagbD4
/q6Slqk+TSjOhTAVfHB1
=MAY1
-----END PGP SIGNATURE-----

Alasdair Kergon (18):
      Speed up CRC32 calculations by using a larger lookup table.
      was renamed
      drop an unnecessary 'stack'
      Speed up unquoting of quoted double quotes and backslashes.
      Add dm_zalloc and use it and dm_pool_zalloc throughout.
      Allow CC to be overridden at build time (for 'scan-build make').
      Add --setuuid to dmsetup rename.
      restrict last checkin to devs consisting entirely of error target
      Don't take write lock in vgchange --refresh, --poll or --monitor.
      Add global/metadata_read_only to use unrepaired metadata in read-only cmds.
      Use a more-generic name for the new kernel flag so list_devices can share it.
      fix header #defines
      pre-release
      post-release
      Update VG metadata only once in vgchange when making multiple changes.
      Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.
      lost line
      pre-release

Dave Wysochanski (42):
      Refactor metadata.[ch] into vg.[ch] for vg functions.
      Refactor metadata.[ch] into pv.[ch] for pv functions.
      Refactor metadata.[ch] into lv.[ch] for lv functions.
      Add lib/metadata/pv.[ch] new files.
      Add lib/metadata/vg.[ch] and lib/metadata/lv.[ch].
      Add {pv|vg|lv}_attr_dup() functions and refactor 'disp' functions.
      Simplify logic to create 'attr' strings.
      Add id_format_and_copy() common function and call from _uuid_disp.
      Add pv_uuid_dup, vg_uuid_dup, and lv_uuid_dup, and call id_format_and_copy.
      Add tags_format_and_copy() common function and call from _tags_disp.
      Add pv_tags_dup, vg_tags_dup, lv_tags_dup functions that call tags_format_and_copy.
      Add supporting functions vg_name_dup, vg_fmt_dup, vg_system_id_dup.
      Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
      Add 'get' functions for vg fields.
      Add pv_mda_size, pv_mda_free, and pv_used functions, call from 'disp' functions.
      Add pv_name_dup() and pv_fmt_dup() helper functions.
      Add pv 'get' functions for all pv properties.
      Add pv_get_property and create generic internal _get_property function.
      Update WHATS_NEW for commits related to generic property functions
      Fix copyright dates on new files lib/metadata/{lv|vg|pv}.[ch].
      Rename 'flags' to 'status' for struct metadata_area.
      Add some lv 'get' functions that require no refactoring.
      Refactor and add code for (lv) 'lv_path' get function.
      Refactor and add code for (lv) 'origin_size' get function.
      Refactor and add code for (lv) 'move_pv' get function.
      Refactor and add code for (lv) 'convert_lv' get function.
      Refactor and add code for (lv) 'lv_kernel_{major|minor}' get functions.
      Refactor and add code for (lv) 'mirror_log' get function.
      Refactor and add code for (lv) 'modules' get function.
      update WHATS_NEW
      Fix lv_modules_dup segfault.
      Refactor and add code for (lv) 'lv_name' get function.
      Refactor and add code for (lv) 'lv_origin' get function.
      Add lv_read_ahead and lv_kernel_read_ahead 'get' functions.
      Rename fields in lvm_property_type.
      Add lv_get_property() internal lvm function.
      Add 'is_integer' flag into internal lvm_property_type.
      Add lvm_vg_get_property() generic vg property function.
      Add lvm_pv_get_property() generic function to obtain value of any pv property.
      Add lvm_lv_get_property() generic function to obtain value of any lv propert
      Add interactive tests for lvm_{pv|vg|lv}_get_property().
      Update WHATS_NEW for lvm2app property functions

Jonathan Earl Brassow (1):
      Fix for bug 637936: killing both redundant logs causes deadlock

Mike Snitzer (4):
      Convey need for snapshot-merge target in lvconvert error message and man
      Never scan a device which is using the error target
      Explicitly have grep print the matching filenames (needed to
      Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.

Milan Broz (1):
      Restrict lvm1 partial mode.

Peter Rajnoha (4):
      Fix memory leak of vg_read while using live copies of metadata in directories.
      Allocate buffer for reporting functions dynamically to support long outputs.
      Use dm_strdup/dm_free instead of strdup/free.
      Clarify error messages when activation fails due to activation filter use.

Petr Rockai (30):
      test-utils: Fix a slight bug in the dmeventd-already-running error message.
      Add an option to skip some tests in make check (regex based, like T=): eg.
      Make lvconvert respect --yes/--force in the inactive log conversion
      Implement vgextend --restoremissing (BZ 537913), which makes it possible to
      Add a test for vgextend --restoremissing.
      Update WHATS_NEW.
      Give correct error message when creating a too-small snapshot (BZ 587063)
      Update WHATS_NEW.
      Limit repeated accesses to broken devices.
      Update WHATS_NEW.
      Tweak the lvm.conf comment about devices/disable_after_error_count.
      Tweak WHATS_NEW for devices/disable_after_error_count.
      Add a VERBOSE option to make check (make check VERBOSE=1).
      Fixes for the devices/disable_after_error_count documentation.
      Implement automatic snapshot extension with dmeventd, and add two new options
      Update WHATS_NEW.
      Avoid an extraneous orphans unlock in vgextend --restoremissing.
      Fix a deadlock in clvmd.
      Revert some debug statements that slipped in with last checkin.
      Implement dmeventd -R, allowing dmeventd to be restarted without losing
      Add a test for BZ 509182 (vgchange --monitor y breaks with max_lv).
      Reduce a (huge) timeout in t-mirror-names.
      Let's rely on the exit code and do not test for empty output.
      Use a more generous timeout for dmeventd in t-lvconvert-repair-dmeventd.
      Fix a double close in clvmd.
      Update WHATS_NEW.
      Add a missed test for dmeventd -R.
      Alasdair correctly pointed out that if the two closes are concurrent (I haven't
      Add code to the dmeventd snapshot plugin to automatically unmount snapshots
      Update WHATS_NEW.

Zdenek Kabelac (51):
      Add missing cleanup rule for generated .exported_symbols_generated
      Maps fix
      Fix leaked pool report
      Fix memory leak of config_tree
      Replace  "can not" with "cannot"
      Fix a serious bug in the behavior of fasdm tool when breaked.
      Correctly respect --dry-run option for fsadm
      Support for passing --yes flag recursively.
      Fix assignment of default LVM variable
      Fix detection of mounted filesystem.
      Fix usage of --yes flag for ReiserFS resize
      Add support for noninterctive shell execution
      Update script for fsadm testing
      Skip fsadm testing until proper installation rules are commited in.
      Don't use floor() in _bitset_with_random_bits
      Fix linking order for liblvm2cmd
      Speedup memory un/locking
      Update
      Fix strict-aliasing compile warning in partition table scanning
      Add coverage test for partition table scanning
      Fix clang warning for ntohl(*((uint32_t *)buf))
      Print vg_name and do not to access vg->name
      Ensure we always have origin defined
      Reuse result of previous strchr
      Fix potential NULL pointer dereference
      Fix missing initilisation to 0
      Switch to char* arithmetic from void*
      Use 'const' struct id *pvid for device_from_pvid()
      rom -> from
      ok this seems to be never ending story...
      Use const pointer for return value of dm_basename
      Fix constness warnings
      Fix constness warning for _vg_read_by_vgid() uuid usage
      Fix constness warning
      Fix constness warning
      Use const config node
      Remove bufused for calculation
      Update C declaration  () -> (void)
      Use static indentifier for internal functions
      Instrument compiler about code unreachability
      Fix NULL pointer dereference for too large MDA error path
      Hotfix usage of __builtin_unreachable()
      Macro uninitialized_var gives warnings in static analysis
      Add missing return for NULL passed buffer
      Return different status code for fsadm check of mounted filesystem
      Add DIAGNOSTICS section to fsadm man page.
      Use new status code from fsadm check
      Use include make.tmpl
      Add given user prefix to make target install_initscripts
      Add OCF support
      Fix include commit and switch to use DISTCLEAN_TARGETS


