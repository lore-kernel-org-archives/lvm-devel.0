From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 23 Nov 2018 03:20:00 -0500
Subject: v2_02_78 annotated tag has been created
Message-ID: <201811230820.wAN8K0T4032133@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c5add066135a98a5da3369404079cc5927b6ccc
Commit:        3c5add066135a98a5da3369404079cc5927b6ccc
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-11-22 16:47 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-11-22 16:47 +0000

annotated tag: v2_02_78 has been created
	    at 3c5add066135a98a5da3369404079cc5927b6ccc (tag)
       tagging 6424bd9e6d0f8ecb3ef007c5a7e93f7cf8ffc75f (commit)
      replaces v2_02_76

Release 2.02.78
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb9t3HAAoJELkRJDHlCQOfstYP+gJaUqJHCW3Wo7isNYv0GNnx
KZhWOL+034S73fxKR0YsWA6U5+mphAinufaSVknnUVybDIrMWee4tQZXNZUWikzy
pTKKVU5J2P/UcynYaKFxehelyTfek3p82VXh+d0q4Itbi8MpJYvnCKykPar+elNG
CFxHuxoIttJyeeTgODUCqrg2PFfgtkflZCVvnD8yVjE20KWHne2I+tBsMvqLJUbO
AE3WU0AfbILlj25Z+g2NXZisnwVpNllsjEqEVYwJeZ/Rpg3ZOQSbValMXSPT3vEr
13n3gEtJ8qUW0vMXj/NzAeO4uXVXXtK47Yofb6ZsRyMlepubagNqddCGd+MnNVVw
bhh9yVpAe1zkkowy++IbdfNbR/I8PQtcCQzdmzNjsFeTA+mV7ATX93LqDRpjDDS8
EiI6hNDyV28/9xxoLjJ/JdbMtn35gMshIq7TnV+kBqsPHiud73FB45nbxCF/uoq3
l9Pf9CWfXOGW960qwlcW+DDv+TZXFeBTZixoptZHxvA94Jr1VuFXcZFVSKesv84T
XCvK7f2PX4YxWhR2J2aUxoOJrNvSkw1fM2xW+gpl3lvCiu3tcD5kyRSfDak9ZIRC
JP4I9teJq+Ab2D+oTi1bxADNj8A0+UMYvbWti+hzDCBV2keF55+2yslyJKyGZu2f
9rpUUZcF/1RyQos7OM3i
=+0tW
-----END PGP SIGNATURE-----

Alasdair Kergon (14):
      post-release
      forgotten to regenerate last time configure.in was updated
      Regenerate configure with 'autoreconf' for --enable-ocf. (2.02.76)
      Extend cling allocation policy to recognise PV tags (cling_by_tags).
      Support repetition of --addtag and --deltag arguments.
      Remove tag length restriction and allow / = ! : # & characters.
      Fix _output_field crash from field_id free with DEBUG_MEM. (Phillip Susi)
      pre-release
      post-release
      Fix default /etc/lvm permissions to be 0755. (2.02.66)
      Suppress 'No PV label' message when removing several PVs without mdas.
      Fix memory leak when VG allocation policy in metadata is invalid.
      Fix debug logging of derived flag LCK_CACHE in clvmd.
      pre-release

Mike Snitzer (1):
      Fix "it's" typo to be "its" in lvconvert error message.

Peter Rajnoha (1):
      WHATS_NEW FIXME

Petr Rockai (22):
      Add generic infrastructure to internal library to 'set' a property.
      Implement lvm_vg_set_property() by calling internal 'set' property function.
      Add vg_set_property to the interactive lvm2app test program.
      Make value.string const char *, in properties.h, to fix a warning introduced by
      Add a new type and function to lvm2app to enumerate lvsegs.
      Add the macro and specific 'get' functions for lvsegs.
      Add lvm2app function to query lvseg properties.
      Add a new type and function to lvm2app to enumerate pvsegs.
      Add the macro and specific 'get' functions for pvsegs.
      Add lvm2app function to query pvseg properties.
      Update interactive tests for lvm2app lvseg and pvseg apis.
      The _free_vg that is created as a placeholder when reporting segments in pvs
      This patch adds helpers to allow users to lookup a lv or pv handle by
      This patch adds helpers to allow users to lookup a lv or pv handle by
      Add interactive tests for functions to lookup a pv|lv by name|uuid.
      All 'size' values of lvm2app properties should be in bytes.
      Disallow certain lvconvert operations that need to both allocate and free
      Update WHATS_NEW.
      Avoid the automatic MISSING_PV recovery path in commands with special
      Fix a failing test (it used a combination of lvconvert parameters that is no
      Refactor the percent (mirror sync, snapshot usage) handling code to use
      What's new.

Zdenek Kabelac (46):
      Scan also 'mount' output for mounted filesystem.
      Update fsadm regresion
      fsadm fix for downsize of unmounted fs
      Add date configurable variable DATE
      Preserve const for char pointer
      Move va_end(ap)  so we do not leave with return -1 without calling it.
      Move va_end() so it is also used before error path  return
      Add missing  closedir() - fixes resource leak
      Do not call dm_task_destroy with NULL
      Move arg_vgnames from local scope
      Add missing fclose
      Fix resource leak of dlopened pointer
      Fix memory leak in error path
      Add missing destrustion of cmd_context
      Cleanup remove test for NULL
      Fix check for empty system_dir
      Remove printing of LCK_CACHE
      Reset vg pointer after release
      Remove dead assignment in _lock_for_cluster
      Remove dead assignment in lvm2_main
      Remove unused 'i' in _pv_analyze_mda_raw
      Remove dead assignment in 'main'
      Remove dead assignment in dm_tree_node_add_mirror_target_log
      Use one fprintf call for usage print
      Fix memory leak in error path
      Remove dead assignment in _mirror_emit_segment_line
      Remove dead assignment in _step_matcher
      Remove dead assignment in wait_for_child
      Optimize lookup table read
      Check reallocated buffer for NULL before use
      Replace snprintf with dm_snprintf
      Add missing test for failed pool allocation
      Remove check for lv is NULL
      Add error path stack traces
      Add stack trace for error path
      Test uuid for NULL
      Remove unneeded test for NULL
      Fallback to full rescan for missing device
      Optimize second call to strchr with same parameters
      Check result of vginfo_from_vgname
      Add logging for pipe write() and close() error
      Test lv_name is not NULL
      Log error from unlink failure
      Add backtraces for errors
      Check lv_info() success
      Check str_list_add() success


