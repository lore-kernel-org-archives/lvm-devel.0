From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Tue, 17 Oct 2023 20:20:23 +0000
Subject: [Git][csonto/lvm2][main] 306 commits: device_id: ignore leading and trailing spaces for sys_wwid and sys_serial
Message-ID: <652eec87a7259_2c228eb586451f@gitlab-sidekiq-low-urgency-cpu-bound-v2-65f69dcbf-wg68r.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at Marian Csontos / lvm2


Commits:
228a8e8c by David Teigland at 2023-06-15T15:17:14-05:00
device_id: ignore leading and trailing spaces for sys_wwid and sys_serial

Leading and trailing underscores are also ignored to handle device ids
written by previous versions which replaced all spaces with underscores.

- - - - -
7c3eca83 by David Teigland at 2023-06-16T12:11:51-05:00
lvresize: fix multiple mounts

which was mistaken as a mounted LV that had been renamed.

- - - - -
1dbb86f8 by David Teigland at 2023-06-20T13:13:06-05:00
tests: lvresize fs mounted multiple times

- - - - -
ea6b5b69 by David Teigland at 2023-06-20T15:47:01-05:00
lvcreate: allow thin snapshot syntax that broke

The command &quot;lvcreate --type thin --snapshot ...&quot; to create a thin
snapshot would fail.

commit d651b340e68d97ada25e558eb50aa40062bba936 removed the optional
&quot;--type thin&quot; from the command definition &quot;lvcreate --snapshot LV_thin&quot;,
and added --type thin as AUTOTYPE.  This was correct and should not have
changed anything if all the command defs were correct, but it broke
the &quot;lvcreate --type thin --snapshot&quot; case.  It reveals a problem in a
different command definintion:  &quot;lvcreate --type thin LV_thin&quot; that was
missing --snapshot in its OO list.

- - - - -
657dde62 by Zdenek Kabelac at 2023-06-23T18:05:03+02:00
lvm_import_vdo: correct the converted virtual size

Ensure the volume after conversion has the properly aligned size to the
volume group extent size. This would be visible when using virtual size,
that cannot be divided by extent size.

Before the user had to manually adjust the size after conversion to get
access to all data stored on VDO volume.

- - - - -
8d09124c by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
tests: update test for automatic virtual size correction

lvm_import_vdo will adjust the virtual size within conversion
so the volume can be use without any futher tweaking.

- - - - -
fec3087e by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
thin: add cfg support for thin_restore and cache_restore

Add configurable paths for thin_restore and cache_restore.

- - - - -
2cb43449 by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
tests: fix path to dev dir

Correct some explicit references to /dev and use $DM_DEV_DIR.

- - - - -
39d6a960 by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
tests: ensure test defines its own etc dir

Compilation may configure it&#39;s own /etc path so ensure the test
has a defined location for access to this dir during testing.

Also prepare machine_id filei (with the use of uuidgen tool)
for the test.

- - - - -
aed91e49 by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
tests: improve test for machine_id

- - - - -
a1d5fba6 by Zdenek Kabelac at 2023-06-23T18:06:22+02:00
aux: add configuration for thin_restore and check_restore

- - - - -
46fe47b8 by Zdenek Kabelac at 2023-06-23T18:08:03+02:00
debug: add backtraces

- - - - -
9756824f by Zdenek Kabelac at 2023-06-23T18:08:10+02:00
make: generate

- - - - -
0a5712ad by Zdenek Kabelac at 2023-06-23T18:08:10+02:00
WHATS_NEW: update

- - - - -
5848f752 by Zdenek Kabelac at 2023-06-25T12:00:57+02:00
tests: correct generated metadata

Newer thin_check actually rejects such restored data.

- - - - -
04860b63 by Zdenek Kabelac at 2023-06-25T13:02:36+02:00
tests: correct checked devices

Fix the testing logic.
With raid5 device the layout of files on a filesystem does not define
which leg will actually contain the block we try to damage.
So test will now figure out which device has damaged block.

Use &#39;check&#39; functionality and also drop unneeded random write as we
now can identify easily in other way.

- - - - -
b8db2c0a by Zdenek Kabelac at 2023-06-25T13:02:36+02:00
tests: require raid target

- - - - -
fa434a18 by Zdenek Kabelac at 2023-06-25T13:02:36+02:00
tests: simplify

- - - - -
6ff65e67 by Zdenek Kabelac at 2023-06-29T13:10:42+02:00
vdo: check_point_frequence is unused option

This vdo parameter existed in the early stage of integration of vdo into lvm2,
but later it&#39;s been removed from vdoformat tool - so actually if
there would be any non-zero value it would cause error on lvcreate.
Option was not stored on disk in lvm2 metadata.

Remove this vdo parameter from lvm2 sources.

(Although this vdo parameter will be still accepted on cmdline through
 --vdosettings option, but it will be ignored.)

- - - - -
e48c9826 by Zdenek Kabelac at 2023-06-29T13:10:42+02:00
vdo: indent for lvdisplay

- - - - -
8b75bbe4 by Zdenek Kabelac at 2023-06-29T13:10:42+02:00
vdo: lvm_import_vdo correct parsing output

Output from vdo manager may actually indent output with spaces,
so trim leading and ending space.

Also add support for verbosity flag for vdo conversion tool.

- - - - -
8a07f57b by Zdenek Kabelac at 2023-06-29T13:10:42+02:00
lvm_import_vdo: spelling fixes

- - - - -
35965588 by Zdenek Kabelac at 2023-06-29T13:10:42+02:00
lv: more details about monitoring lvs

Show &quot;not supported&quot; when LV does not support dmeventd monitoring.
Show &quot;disabled&quot; for LV with disabled dmeventd monitoring.
(lvdisplay -m)

- - - - -
e84b0096 by Zdenek Kabelac at 2023-06-29T13:55:27+02:00
pool: avoid using artificial name internally

- - - - -
b90c5d60 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
vdo: support version 4

Properly parse VDO volumes formatted with geometry block version 4.0.

- - - - -
5154054a by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
snapshot: no error when extending above max size

When lvm2 calculates the maximal usable COW size and crops the user
requested size to this value, don&#39;t return the error result from
the &#39;lvextend&#39; operation.

We already apply the same logic when resizing thin-pool beyond
the supported maximal size.

FIXME: The return code error logic here is somewhat fuzzy.

- - - - -
d43a79ee by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
segtype: add missing macros for error and zero segment

Add macros for checking error and zero segment as we do
with other segtypes.

- - - - -
44b07041 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
commands: support query for lv_is_cow

- - - - -
22642905 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
commands: enhance error checking for generator

No exit value 0, when the parser hits an error.
Increase some buffers since as some arg lists are getting longer.

- - - - -
5175e87f by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
commands: error and zero segtype handling

Add function to work with error and zero LVs more easily.

- - - - -
558890ad by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
pool: support passing data_lv for recalculation

Support data_lv to be passed as parameter when it&#39;s not yet
attached to the pool.

- - - - -
9bbbc1b2 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cachepool: skip wipe for nonzeroeable segments

Avoid activation when going to skip zeroing of &#39;error&#39; segtype
(so it&#39;s not erroring out).
Also skip zeroing for &#39;zero&#39; segtype LV (already being zero).

- - - - -
0dee6fc2 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cache: handle error segtype

Allow to convert error LV.

- - - - -
88f1e7a9 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cache: support more segtypes for caching

Enable support to cache thin/error/zero virtual targets.

Use can now select whether he want to cache whole thin-pool,
or an individual thin volume out of whole thin-pool.
Support using zero and error LVs as data volume for
cachepool is possibly useful for benchmarking, not much
can be expected from such setup.

- - - - -
e36028b7 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cache: update validation rules

Validate cache origin in front of the prompt.
Also add some rules to command description file.

TODO:
more validation needed also for lvcreate,
more complex rules with &quot;OR&quot; seems to be needed.

- - - - -
e022805f by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
pool: do not pass empty string in callback

When preparing cmdline to executing dmpd tool, avoid adding
empty string (&quot;&quot;) on such line.

- - - - -
077b46e0 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
lv_manip: fix move_lv_segments moved bits

For proper functionality of insert_layer_for_lv we need to
move more bits to layerd LV.

Add some missing new types and correct usage of caller,
so the new LV type is set after the movement.

- - - - -
975368ba by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
tests: skip on kernels

- - - - -
721bee1b by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
tests: cache with error and zero

- - - - -
98a34e43 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
tests: caching of single thin volume

- - - - -
96123b90 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cleanup: use spelling synchronize

Use single spelling form for synchronize.

- - - - -
f35fa8c1 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
cleanup: typos

- - - - -
39457234 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
lvconvert: support conversion to thin volume

Update pool conversion function to handle also conversion of
thick LV to thin LV by moving thick LV into thin pool data LV
and creating fully provissioned thin LV on top of this volume.

Reworking existing conversion to use insert_layer_for_lv co
the uuid is now kept with thin-pool - this should however not
really matter as we are doing full deactivation &amp; activation cycle.

With conversion to thin LV user can use same set of arguments
to set chunk-size.

TODO: add some smart code to decide best values for chunks sizes.

- - - - -
70c911b6 by Zdenek Kabelac at 2023-07-10T17:13:32+02:00
pool: improve message for data persistance

Inform a user that pools using either error or zero LVs are
not able to keep any data persistant.

- - - - -
9ba9e997 by Zdenek Kabelac at 2023-07-10T17:13:33+02:00
man: update for new syntax

- - - - -
93581345 by Zdenek Kabelac at 2023-07-10T17:13:33+02:00
tests: update thin

- - - - -
9abcf5cb by Zdenek Kabelac at 2023-07-10T17:13:33+02:00
tests: use aux functionality

Use aux wait_recalc and wait_for_sync  for faster processing.

- - - - -
00b5d7b0 by Zdenek Kabelac at 2023-07-10T17:13:33+02:00
lv: followup seg_monitor reporting

With 3596558861e62ca0c6f37bfba6a4e80e46dcca47 it&#39;s been introduced
a more fine grained description.
However &#39;disabled&#39; might be actually more confusing then empty field,
so keep only the info about &#39;not enabled&#39;aka dmevend is not allowed
to monitor LV which otherwise could be monitored.

- - - - -
52f939ca by Zdenek Kabelac at 2023-07-10T17:13:33+02:00
WHATS_NEW: updates

- - - - -
b3b6c6b5 by Marian Csontos at 2023-07-10T18:03:51+02:00
README: Move to gitlab

- - - - -
857f5d6e by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
lvconvert: correction for thin conversion

Updates for 39457234db1d92f89d4234e2f2f5b703206281ae.
Off-by-one for option array - need 20 fields.
Missed to clear lock_args for cachepool.

- - - - -
4c78bdcf by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
autoconf: update py-compile

Use newer version of this script from:
https://raw.githubusercontent.com/autotools-mirror/automake/4bd4640e03670e267d9763d377f107c09b4f2202/lib/py-compile

Reported-by: Adam Willamson

- - - - -
491ee5d1 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
cov: hide some messages

Living with these...

- - - - -
7ec97ed5 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
cov: fix memleak in vgchange

Release allocated  vgname from get_single_vgname_cmd_arg()
when it is not returned via *vgname_ret.

- - - - -
c38b668f by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
debug: fix parsing of /proc/self/stat

The code in init_log_file relies on the process name (COMM) to not
contain whitespaces. This change fixes it by looking up the right-most
parenthesis to safely jump past COMM.

For more context see:
https://www.openwall.com/lists/oss-security/2022/12/21/6

Code is only used with testing, so it should have no impact on regular
users.

Reported-by: Hugues Evrard &lt;hevrard at google.com&gt;

mm

- - - - -
4d70e7bf by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
debug: use display_lvname

- - - - -
a51c68aa by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: makefile build proper tools list

Add compiled components to the list.

- - - - -
80bad4a3 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: check for writecache presence

Test is using writecache.

- - - - -
85fb46d8 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: reduce paths added to LD_LIBRARY_PATH

Add only stricly needed paths to compiled .so objects.

- - - - -
33f02261 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
tests: some fixes for lvmlockd testing

- - - - -
6f1318c4 by Zdenek Kabelac at 2023-07-12T15:18:38+02:00
WHATS_NEW: update

- - - - -
6e3b5168 by Marian Csontos at 2023-07-12T15:53:45+02:00
Update README

- - - - -
cb2d32bd by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
debug: fix sscanf type

Last commit c38b668fc3ead664a35130c1acec63518630d1dc was pushed
with type &#39;scanf&#39; instead of &#39;sscanf&#39; needed for buffer reading.
Interestingly this caused scanning from &#39;stdin&#39; descriptor and
thus failures in lvm shell usage.

- - - - -
64b28e08 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
lvchange: add log_error for failure path

When change of monitoring fails, ensure there is log_error() printed.

- - - - -
5ce236a6 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
gcc: correct signess comparation

Compare int to int and unsigned to unsigned...

- - - - -
f8712c6c by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
makefiles: remove autom4te.cache

For &#39;make distclean&#39; remove also autom4te.cache
(from autoreconf).

- - - - -
7171260b by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
makefiles: install lvmdbusd executable

Use a different mechanism to ensure, lvmdbudd is executable at
install destination.

- - - - -
ae512e20 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: skip test if daemon is running

Skip the test, to avoid making all test failed when there is
&#39;left&#39; daemon running.

- - - - -
2ecd290c by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: use conf=fdatasync

Since we write here in 1k blocksize - we can&#39;t use direct.

- - - - -
4ae2dde5 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: update

Just drop debug log in case of error happenig later,
so we do not print uneeded info...

- - - - -
f24eb81d by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: improve LD_LIBRARY_PATH setting

Some linkers do need libdevmapper-event-lvm2.so.2.03,
so add also this symlink to the tests  /lib dir.
This fixes the need to use previous LD_LIBRARY_PATH complex
setting and now works with much shorter list.

- - - - -
97fc0ca4 by Zdenek Kabelac at 2023-07-13T21:52:20+02:00
debug: missed properly modify pointer type

- - - - -
93484c2a by Zdenek Kabelac at 2023-07-13T21:56:47+02:00
man-generator: ensure p is defined

In error path, p pointer could have been undefined.

- - - - -
bdcfd2d7 by Zdenek Kabelac at 2023-07-14T16:20:30+02:00
lvconvert: no metadata for test mode

Avoid trying to build real metadata in --test mode.

- - - - -
8eb3a5b5 by Zdenek Kabelac at 2023-07-14T16:51:46+02:00
lvconvert: thin convert locking

Fix locking when converting thick to thin LV, ensure
we take pool lock for shared VG.

- - - - -
75b28ab4 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvmlockd: query the simplest check first

Check for visibility of the LV first.

TODO:

Short check list and test only for those that can&#39;t be locked,
but they are visible LVs.

- - - - -
8cbba1d1 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvmlockd: enable vdo conversion

As we turn &#39;already&#39; active/locked LV into a data LV of vdopool,
we just keep active lock for such volume (uuid is preserved).

- - - - -
a2b2ae35 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvresize: improve usepolices

lvresize --usepolicy requires resized LVs to be active.
(So it&#39;s not only required for shared VG).

The test for active pool needs to use lv_info to query &#39;layer&#39;
otherwise the pool is considered inactive if it was not activated
explicitely - thun &#39;implicit&#39; activation with VDO or ThinLV was
not managed by --usepolicy option.

- - - - -
b89fc056 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
cleanup: indent

- - - - -
a9977146 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
tests: skip with lvmpolld

Not needed with lvmpolld pass.

- - - - -
482501c2 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
tests: more checks with active thin lv

Check --usepolicy works primarily when thin-pool -tpool is there.
Also let the test run with lvmlockd.

- - - - -
1c60c678 by Zdenek Kabelac at 2023-07-14T16:53:34+02:00
tests: check --test

Check lvconvert --thin is not adding more LVs.
Enable testing with lvmlockd.

TODO: lvmlockd is missing support for --test.

- - - - -
fdf25716 by Zdenek Kabelac at 2023-07-15T11:05:06+02:00
mm: add libzstd to ignore list

No need to lock-in-RAM libzstd (linked from systemd).

- - - - -
b3e45219 by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
lvconvert: hanle metadataswap with lvmlockd

- - - - -
81ef1fd0 by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
debug: print WARNING:

Add WARNING: in front of log_warn() messages.

- - - - -
914d7938 by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
aux: fix version checking

New dmpd tools return version string in different format,
so update code to understand both variant.

Also hide some shell var setting to local functions.

- - - - -
f71d3cce by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
tests: ensure single leg is broken

Make sure only the first raid5 leg, that contains searched string
is being modified, so we do not &#39;damage&#39;  2legs at once.

- - - - -
ac25dd9b by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
tests: faster check for flushing

Try minimizing delay in detecting &#39;cleaner&#39; policy precence,
so we can fast interrupt running lvconvert.

- - - - -
9b23ff5d by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
tests: add fsck before resize2fs

- - - - -
55b498b6 by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
tests: avoid using /test dir

Keep using test directory for created files.
Trap errors and remove brd in this case.
Use some shell builtins to reduce fork count.
Use &quot;$VAR&quot;.
Run &#39;pvs&#39; with devlist (so not acceing other system devices).

- - - - -
f6104adc by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
tests: updates

Pass more args with some &#39;aux&#39; commands:
wipefs_a, enable_dev, disable_dev
(so it&#39;s a bit more efficient using single udev_wait call).
Use prepare_vg instead of prepare_pvs.

- - - - -
0670338e by Zdenek Kabelac at 2023-07-15T11:05:35+02:00
WHATS_NEW: update

- - - - -
c5e43263 by Zdenek Kabelac at 2023-07-17T12:43:39+02:00
active: device name limit is NAME_LEN

Use existing NAME_LEN instead of 257 value.
Add missing backtrace.

- - - - -
f78b0247 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lv_manip: refactor code

Simplify initialization of exec buffer.
Check for misconfigured &#39;fsadm&#39; executable path.

- - - - -
4d231165 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvm-exec: refactor code

Add prepare_exec_args() for reading option list for
thin/cache_repair, thin/cache_check.

- - - - -
409a7962 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
vdo: refactor code

Shuffle code to use prepare_exec_args().
Simplify generation of options string within a single char buffer.

- - - - -
d040b68a by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: use public LVs for recovery

Replace the use of internal /dev/mapper names with the use of
public LV names /dev/vg/lv for use with repair tools.
For this make the activation of _pmspare LV to be handled as
a component activation with public name.
Metadata is already atomatically activated this way (as readonly).

So if there is any &#39;error&#39; happening, we leave public LVs in
system.

- - - - -
f078ffc5 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: add support --setactivationskip

When repair thinpool or cachepool, lvm2 leaves original metadata
volume backup. To avoid potential damage of those data, mark such
volume as &#39;read-only&#39; and also allow user to use --setactivationskip
option for this volume.

TODO: likely better default would be to automatically skip, but
that might need some more thinking about recovery reporting doc.

- - - - -
d6771e51 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: code shuffle

Use cachepool name for create name for metadata backup LV.
(so we do not generate 2 &#39;sequences&#39; of metadata filenames.)
Move path preparion before handling _pmspare.
Also drop extra call to sync_local_dev_names() as it&#39;s
already got in sync with call of exec_cmd().

- - - - -
469bcc28 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
cleanup: remove duplicated code

Commit cac4a9743acb826d785c0e51e9a752d8959ced80 moved setting
if layer structed to the function front, but the old code
was still left in original place.

- - - - -
09e17f99 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
cleanup: remove double //

dev_dir ends with /.

- - - - -
96b2c209 by Zdenek Kabelac at 2023-07-17T12:44:37+02:00
debug: add backtrace

- - - - -
284fdb17 by Zdenek Kabelac at 2023-07-17T12:44:48+02:00
tests: mark test as warning

Until more universal solution for thin-pool corruption gets in place.

- - - - -
06e39625 by Zdenek Kabelac at 2023-07-17T13:21:59+02:00
tests: check for loaded brd

Skip the test if the brd is already loaded in the system.

- - - - -
39cc12e7 by Zdenek Kabelac at 2023-07-17T13:42:58+02:00
tests: use zero device

Change the test to use &#39;zero&#39; backend, so we could use larger size
and get &#39;larger&#39; buffer of dirty blocks for fast CPUs...

- - - - -
ace8a2a8 by Zdenek Kabelac at 2023-07-17T13:47:57+02:00
WHATS_NEW: update

- - - - -
32b2e416 by Zdenek Kabelac at 2023-07-17T14:30:39+02:00
tests: new logic for repair

meta name deduced from cachepool name.

- - - - -
1c278235 by Zdenek Kabelac at 2023-07-17T16:22:29+02:00
vdo: use long --verbose

vdo tools needs long option.

- - - - -
b2431d10 by Zdenek Kabelac at 2023-07-17T16:34:14+02:00
tests: catch all output

Previous fix was invalid (after some in-place shuffling)
&#39;dd&#39; copied goes to &#39;stderr&#39; so we need to catch all output.
Grep needs to check output of tee tool.
Ensure &#39;C&#39; locales are in use with &#39;dd&#39;.

- - - - -
e3cc3e55 by Paul van Genderen-Tjie A Loi at 2023-07-24T12:03:06-05:00
vgmknodes: skipping thin pool is not an error

- - - - -
7cc41413 by David Teigland at 2023-07-24T14:56:32-05:00
lvmdevices: add --delnotfound to delete entries for missing devices

Used with update: lvmdevices --update --delnotfound.
Removes all devices file entries for which no matching device is found.

- - - - -
0e9fe272 by Peter Rajnoha at 2023-07-31T13:44:09+02:00
report: fix pv_major and pv_minor report field type

We incorrectly marked pv_major and pv_minor fields as being of string
type, even though the values were already correctly handled as integers
internally. This confused -S|--select that tried to compare string
values instead of integers.

Reported here: https://github.com/lvmteam/lvm2/issues/122

- - - - -
9385bea5 by Marian Csontos at 2023-08-02T12:22:16+02:00
make: generate

- - - - -
1fe2a749 by Marian Csontos at 2023-08-02T14:38:23+02:00
WHATS_NEW: update

- - - - -
016e469c by Marian Csontos at 2023-08-02T14:41:12+02:00
pre-release

- - - - -
606ecae5 by Marian Csontos at 2023-08-02T14:42:16+02:00
post-release

- - - - -
abdb87dd by Marian Csontos at 2023-08-03T11:00:23+02:00
CI: Add .gitlab-ci.yml

- - - - -
847f1dd9 by David Teigland at 2023-08-04T11:45:40-05:00
device_id: rewrite validation of devname entries

The old approach was too complicated and didn&#39;t work correctly
in some cases.

- - - - -
2928891b by David Teigland at 2023-08-08T16:57:22-05:00
lvconvert swapmetadata: fix lvmlockd locking

The lockd lock needs to be freed for the LV that is becoming
the new metadata LV, and a new lockd lock needs to be created
for the old metadata LV that is becoming an independent LV.
Fixes b3e45219c2f4

- - - - -
ac36153e by Zdenek Kabelac at 2023-08-14T17:02:09+02:00
lvconvert: preserve UUID for swapped metadata

When swapping metadata LV for a pool volume, preserve UUID for metadata
LV during the swap - this allows to better utilise locks with lvmlockd.

- - - - -
80377eeb by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: preserve UUID on pool repair

Once lvm2 repairs pool&#39;s metadata LV and preserves the original metadata LV
with unmodified metadata, for such LV in VG use newly created UUID for new
_pmspare and actually preserve UUID for this hidden _pmspare (if it
exists).

- - - - -
0b7239eb by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: fix ret values fro integrity remove

Fix return value from _lvconvert_integrity_remove()
as it is expected to match _add() and be 0/1.

Also add some missing log_error() messages.

- - - - -
2f3d8659 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
commands: add lv_is_writable

- - - - -
23019946 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: vdo needs writable LV

- - - - -
741a166f by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: use common error exit path

- - - - -
ee6519f8 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: use just single label

- - - - -
b764665f by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: add missing log_error

Report error with failure.

- - - - -
060491c4 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
WHATS_NEW: update

- - - - -
e548afd1 by David Teigland at 2023-08-15T13:13:06-05:00
lvconvert swapmetadata: update lvmlockd locking for uuid exchange

lvmlockd locking for swapmetadata adjusted for commit
ac36153e9943 lvconvert: preserve UUID for swapped metadata

Now that the LV uuid is swapped between LVs, the lvmlockd lock can
simply be moved between them, and the same lock can continue to be
used for the LV outside of the pool.

- - - - -
13225f13 by Zdenek Kabelac at 2023-08-16T11:25:54+02:00
lvconvert: fix regresion from integrity check

Testing code sliped into commit and cause regression in testing for
a raid with integrity.

- - - - -
54617805 by Zdenek Kabelac at 2023-08-16T13:31:01+02:00
lvconvert: use vg mempool

Keep allocation for a VG within vg memory pool.

- - - - -
41e4cefc by Christian Hesse at 2023-08-16T15:13:00+02:00
make: make install_libexec a target of install_lvm2

This makes sure libexec scripts are available for lvm2 commands.

- - - - -
085c3821 by Zdenek Kabelac at 2023-08-16T15:13:00+02:00
cleanup: no longer used

Previous commit made this var unused.

- - - - -
728617d2 by Zdenek Kabelac at 2023-08-16T15:13:25+02:00
gcc: cleanup warnings

Correcting signess comparation.
Also use standalone /* fall through */ comment as that&#39;s
the only one supported by gcc to quiet warning.

- - - - -
5a96ca4a by Zdenek Kabelac at 2023-08-16T15:14:29+02:00
tests: update pool uuid handling

Pools now preserve meta LV UUID with swapmetadata operation
to make the usage of lvmlockd easier.

Update test to reflect this change.

- - - - -
09619628 by David Teigland at 2023-08-16T15:29:19-05:00
lvmlockd: fix thick to thin lv conversion

- - - - -
696ee52f by David Teigland at 2023-08-16T15:29:20-05:00
lvmlockd: let lockd_init_lv_args set lock_args

Set the lock_args string in addition to doing initialization.
lvconvert calls lockd_init_lv_args() directly, skipping
the normal lockd_init_lv() which usually sets lock_args.

- - - - -
6ca97e6e by David Teigland at 2023-08-16T15:29:20-05:00
lvmlockd: fix lvconvert to thin-pool

- - - - -
8698f9dc by Zdenek Kabelac at 2023-08-17T20:10:21+02:00
pool: use predefined name for metadata LV

While create new LV for pool volume, use name from &#39;pool_metadata%d&#39; naming
sequence. This LV is later on renamed to  pool_t/cmeta, but if there
is any error in the middle, we may evenutally leave some &#39;volume&#39;,
With this name it can be slightly more obvious how it got there,
but also when we handle _pmspare name - we get slightly more predictible
name used there for it.

However for a standard usage this commit shall no visible impact as the
name is used temporarily just for cleaning LV.

- - - - -
ad73f571 by Zdenek Kabelac at 2023-08-17T20:14:47+02:00
lvconvert: move _pmspare handling before conversion

- - - - -
dde5b810 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
lvconvert: run error path code only for shared VG

Error path for locking only for share VG.

- - - - -
ba36ba88 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
cleanup: move allocation code

Allocate new memory after validation passed.

- - - - -
61499e87 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
debug: common error handling

- - - - -
5803d9b6 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
tests: skip some tests with valgrind

Valgrind tends to be too slow for any kind of slowing down,
thus skip some tests that are time sensitive.

- - - - -
73abdedb by Marian Csontos at 2023-08-22T16:39:32+02:00
CI: Add timeout

Increase timeout from default 1h to 2h.

- - - - -
941c4a20 by Zdenek Kabelac at 2023-08-23T13:47:39+02:00
tests: better slowdown

- - - - -
71ff21f5 by Zdenek Kabelac at 2023-08-23T15:10:40+02:00
gcc: initialize variables

- - - - -
c4b42e9f by Peter Rajnoha at 2023-08-28T15:44:00+02:00
gitignore: update

- - - - -
12b60e7c by Peter Rajnoha at 2023-08-28T15:44:57+02:00
libdm: report: support reporting field IDs in headings

Add new DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS report output flag.
If enabled, column IDs are reported instead of column names in report
headings.

The &#39;column IDs&#39; are IDs as found in &#39;const struct dm_report_field_type *fields&#39;
array that is passed during report initialization (that is, a call to
dm_report_init/dm_report_init_with_selection). In this case, the &#39;id&#39;
dm_report_field_type member is used instead of the &#39;heading&#39; member.

- - - - -
14d0a9ee by Peter Rajnoha at 2023-08-28T15:44:57+02:00
report: support printing full column names in report headings

Reuse existing report/headings config setting to make it possible to
change the type of headings to display:
  0 - no headings
  1 - column name abbreviations (default and original functionality)
  2 - full column names (column names are equal to exact names that
      -o|--options also accepts to set report output)

Also, add &#39;--headings none|abbrev|full|0|1|2&#39; command line option
so we are able to select the heading type for each LVM reporting
command directly.

- - - - -
5a1248f1 by Peter Rajnoha at 2023-08-28T15:44:57+02:00
dmsetup: support printing full column names in report headings

Add &#39;--headings none|abbrev|full|0|1|2&#39; command line option to select
the heading type.

  none|0   - no headings
  abbrev|1 - column name abbreviations
  full|2   - full column names (column names are equal to exact names
             that -o|--options also accepts to set report output)

- - - - -
5a6d1369 by Peter Rajnoha at 2023-08-28T15:44:58+02:00
make: generate

- - - - -
2ab2da5e by Peter Rajnoha at 2023-08-28T15:44:58+02:00
man: update lvmreport man page about report/headings and --headings

- - - - -
1f02c5f2 by Peter Rajnoha at 2023-08-28T15:44:58+02:00
tests: add shell/report-headings.sh

- - - - -
092f58a7 by Peter Rajnoha at 2023-08-30T18:37:18+02:00
man: dmsetup: document --headings

- - - - -
65d23a1d by wangzhiqiang at 2023-08-30T15:47:42-05:00
vgchange: acquire an exclusive VG lock for refresh

Concurrent vgchange --refresh commands can lead to hung
tasks in dm code.

Signed-off-by: wangzhiqiang &lt;wangzhiqiang95 at huawei.com&gt;

- - - - -
c37416b6 by David Teigland at 2023-08-31T13:15:07-05:00
lvmlockd: client mutex ordering

Avoid deadlock between threads on mutexes (in theory.)

- - - - -
b81835b5 by Zdenek Kabelac at 2023-09-03T16:01:07+02:00
vdo: lvm_import_vdo uses devname from vdoconf.yml

VDO is using specific path for some device paths.
i.e. for /dev/sda it could be /dev/disk/by-id/scsi-xxxxx.

This used to be not a problem before lvm2 started to use snapshot,
but now it needs to replace matching device path.
So switch to the path naming used in vdoconf.yml file.

- - - - -
c693aa8d by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
vdo: enhance import script for devices file

When the import is used on a system, that uses devices file,
the final activation was impossible for the case the converted
volume was not present in devices file.
Currently add volume automatically in such case.

Also add some more debugging output from the script.

TODO: Consider enhnacing lvconvert with extending devices file.

- - - - -
aa7f2ac9 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
lvconvert: thin conversion accept passed PVs

When creating thin pool or check pool there is allocated LV
for metadata and for such allocation user should be able to
specify list of PVs on cmdline.

Also fix unused passed list of PV for thick to thin conversion,
where the code was using whole PV set from a VG (but since it&#39;s
been not enabled on cmdline, user could not hit this issue).
Also remove unneeded initialization of use_pvh.

- - - - -
29630b2d by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
dmeventd: move var set to locked section

It should not change the actual code flow, however make the
set of the current_event variable inside locked section.

- - - - -
cb61d229 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
filesystem: move stat after open check

To avoid time-of-check-time-of-use clash, take the stat()
after successful open with fstat().
Also add some debugs for failing sys calls.

- - - - -
6a0e54f8 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
clang: ensure status is initilized

Initialize status before handling error path.

- - - - -
a4884726 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
clang: ensure all variables intialized

Just in case of some wierd kernel bug, which would forget
to report these values...

- - - - -
97770d5a by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: check for syscalls

Add some debug checks for possibly failing syscalls.

- - - - -
670d9825 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: drop stack from regular path

- - - - -
d34d1f01 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: trace result failure

- - - - -
9087ace2 by Zdenek Kabelac at 2023-09-03T22:15:48+02:00
aux: teardown also devices with testing UUID

Hunt also for devices with LVMTEST prefix in UUID.

Call teardown_devs_prefixed - so if they hold RAM or SCSI
they are closed before trying to remove kernel modules.

- - - - -
06464f7c by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: vdo wrapper support symlinks

Enhance internal VDO replacement wrapper script to handle symlinks
for i.e. SCSI device like VDO manager.

- - - - -
39f31210 by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: check passing PV list

- - - - -
b85f9c18 by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: vdo convert

Require VDO version 6.2.3.

Skip the part of the test that needs vdo wrapper and 2 different
versions of vdoprepareforlvm to prepare shifted VDO header
at the 2MiB offset.

- - - - -
86cf593e by Zdenek Kabelac at 2023-09-03T22:44:08+02:00
tests: vdo scsi convert

Somewhat tricky test to check VDO import of a SCSI device.

- - - - -
e9eeb840 by Zdenek Kabelac at 2023-09-03T22:51:22+02:00
WHATS_NEW: update

- - - - -
cc8178e9 by Zdenek Kabelac at 2023-09-04T17:48:41+02:00
tests: check for binaries

vdo wrapper tool uses some &#39;locally installed&#39; binaries
for vdoformat and vdoprepareforlvm
Chech for their presence.

Skip this test with lvmlockd.

- - - - -
2b8b5129 by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
tests: check for writecache

Writecache needs writecache kernel target to be present.

- - - - -
5a441352 by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
tests: disable logging for lvmdbusd

Since lvmdbusd testing tends to do its own logging,
try for now to disable very generic logging mechnanism
of the test suite and see the result.

Some lvmdbusd test seems to rely on some log/file logic
which is modified with the use of these shell vars.

- - - - -
2eb34ede by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
make: generate

- - - - -
fa496513 by David Teigland at 2023-09-11T12:18:12-05:00
lvresize: fix 32 bit overflow in size calculation

- - - - -
d9cebeaf by Zdenek Kabelac at 2023-09-12T14:30:48+02:00
vdo: lvm_import_vdo enhancements

Work also with devices that may have &#39;:&#39; inside their generated
/dev/disk/by-id

Ensure there is no race with systems&#39; auto activation while using
the snapshot for conversion.

Update system&#39;s vdoconf.yml after the use of snapshot for conversion.

Skip unnecesary prompt for &#39;convert&#39; while using snapshot and query only
for final snaphot merge.

Prohibit conversion for a device with the PV header.

Enhance &#39;trap&#39; protection for more signals.

Improve clean() recovery path.

Replace bash &#39;test&#39; command with [].

Correct some output message to print $TOOL.

Support also options without &#39;-&#39; in the middle i.e. --nosnapshot.

For shellcheck predefine all variables extracted from vdoconf.yml.

- - - - -
b1b60887 by Zdenek Kabelac at 2023-09-12T14:39:14+02:00
debug: missing dots

- - - - -
ab73ad4e by Mikulas Patocka at 2023-09-12T14:41:22+02:00
gcc: fix warnings for x32 architecture

Warning from x32 ABI compilation.

- - - - -
8cbfd72f by Zdenek Kabelac at 2023-09-12T14:44:32+02:00
WHATS_NEW: updates

- - - - -
e1cfc075 by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
vdo: better support for devicesfile

Instead of relying on &#39;pvs&#39; output - check directly system
configuation and use lvmdevice accrording to use_devicesfile setting.

Also drop use of --fs ignore for filesystem extension for better
backward compatibility with older lvm version.

Shuffle code a bit so the &#39;--no-snapshot&#39; path does not execute
a few unnecessary commands.

- - - - -
e75ac1b4 by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
gcc: warning: missing braces around initializer

Fix warning emitted by some older gcc...

- - - - -
1885655e by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
test: improve aux teardown

Handle the case of device teardown where the first pass
could have only a single, but opened device, for removal.
In such case we want to at least once go through
the udev_wait and retry removal again.

TODO: maybe a sleep .1  might be usable as well with udev_wait

- - - - -
f9688335 by Zdenek Kabelac at 2023-09-14T01:44:27+02:00
vdo: avoid using of valuesonly

To retain backward compatibility with some older version of lvm
avoid using --valuesonly option with lvmconfig.

- - - - -
4276c703 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: aux try with extra sleep

Since udev_wait is not really adding any major delay to wait
for any udev worker processing - add extra sleep .1.

- - - - -
de4cb219 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: aux using singl lvmconf call

lvmconf can handle multiple options in a single pass.

- - - - -
738c4b84 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: missing to check for writecache support

Ono more case requires writecache presence.

- - - - -
fba81cf3 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: pvmove large disk area

With some faster test hw machine we need to make this test
a bit more resource consuming.

- - - - -
fac2e073 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: enforce full fs check

- - - - -
f9d17f1f by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: update for work in fake dev environment

No write outside of $LVM_TEST_DIR  (removed /test access).
Use &#39;aux prepare_scsi_debug_dev&#39; for automated scsi_debug handling
Properly use &quot;&quot; around shell vars.
Smarter read of PVS values.
Relax requirement to only work with real /dev dir.

- - - - -
9d7061f1 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: skip test when lvmdbusd runs on the system

lvmdbusd changes $RUNDIR results.

- - - - -
f5781144 by Zdenek Kabelac at 2023-09-14T10:01:43+02:00
vdo: typo fix

Argh - lastmin mods...

- - - - -
970e4d29 by Zdenek Kabelac at 2023-09-14T10:08:26+02:00
tests: add fsck after split

- - - - -
e2f29c49 by Zdenek Kabelac at 2023-09-19T14:47:27+02:00
pvmove: fix building sibling raid lv name

Make a local copy of the &#39;idx&#39; string to avoid
overlapping during the rebuild of name.

This fixes cases where users specified raid
component LVs for moving.

Reported-by: kotarou3 at github.com

- - - - -
c7c51329 by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
tests: check pvmove with raid legs

Check pvmove correctly handles raid legs on input
(testing previous pvmove fix).

- - - - -
984c024e by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
typos: misc

- - - - -
fc2feabe by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
WHATS_NEW: updates

- - - - -
a8fd6de9 by Zdenek Kabelac at 2023-09-20T15:55:28+02:00
lvmdbusd: fix syntax warning

python3.12 reported SyntaxWarning: invalid escape sequence &#39;\/&#39;

- - - - -
90713c84 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: enhance timestamp for debugging

Add microseconds for timestamps in dm-event trace messages.
Also collect timestamps only when debugging when they are used.

- - - - -
a203499b by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: release buffer on dm_event_get_version

Avoid memory leak in this function.

- - - - -
39602471 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: reset descriptors

Reset descriptors after closing them to -1.

- - - - -
c31dcf36 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: use return

Use &#39;return&#39; instead of calling exit() when possible.

- - - - -
637d812d by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: unregister all devices on restart

Instead of just exiting in the middle of monitoring,
unregisted all monitored devices first and then exit.

To speedup this path, all send internal SIGINT when thread
unregiters itself, to wakup-up main sleeping loop.

- - - - -
80d34abf by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: info status report

To quickly get info about some internal dmeventd status,
implment   &#39;dmeventd -i&#39; support.

Reported messages are some &#39;raw&#39; internal informations mainly
useful to developers.

- - - - -
744cdc3b by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
configure.ac: add --with-dmeventd-exit-on-path

- - - - -
3da18a06 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
configure: autoreconf

- - - - -
a9d7a9d1 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: implement exit_on file check

When exit on file is present in a system and term/break signal is
catched, them dmeventd is no longger refusing to exit.

For the correct shutdown, there should be ideally unmonitoring call,
however in some case it&#39;s very hard to implement this correct procedure.

With this &#39;exit on&#39; file dmeventd at least avoid &#39;blocking&#39; shutdown,
before systemd kills use with -9 anyway possibly even in some unwanted
stated of internal dmeventd processing (i.e. in the middle of some lvm
command processing).

- - - - -
e930ee93 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
debug: correct level

No error for just tracing message.

- - - - -
d54deae0 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
debug: correcting check for error

Correct trace for erroring case of close.

- - - - -
cb8486a9 by Zdenek Kabelac at 2023-09-26T01:24:38+02:00
tests: check exit_on works

- - - - -
d0637837 by Zdenek Kabelac at 2023-09-26T01:32:48+02:00
WHATS_NEW_DM: update

- - - - -
88aa285a by David Teigland at 2023-09-27T15:22:11-05:00
devices: refresh device ids if the system changes

If the system changes, locate PVs that appear on different devices,
and update the device IDs in the devices file.  A system change is
detected by saving the DMI product_uuid or hostname in the devices
file, and comparing it to the current system value.  If a root PV
is restored or copied to a new system with different devices, then
the product_uuid or hostname should change, and trigger lvm to
locate PVIDs from system.devices on new devices.

- - - - -
df9e5f39 by Zdenek Kabelac at 2023-10-02T14:13:12+02:00
debug: correct check for failing close

- - - - -
d7b4a4ce by Zdenek Kabelac at 2023-10-02T14:13:12+02:00
debug: stacktracing failure

- - - - -
e3dd3424 by Zdenek Kabelac at 2023-10-02T14:24:04+02:00
tests: enhance runner

Add Timespec class to increase time resolution to miliseconds
(can switch to microseconds if ever needed).
Use more const and const_interators and pass by reference.
Output rusage also to list result file.
Reduce inlining of C++ constructors.

- - - - -
529fe9ef by Zdenek Kabelac at 2023-10-02T14:25:52+02:00
tests: aux reuse already pgrep of dmeventd

Test already checks if there is any dmeventd running in the system
in the inittest.

- - - - -
368ab305 by Zdenek Kabelac at 2023-10-02T14:25:52+02:00
tests: reduce slowing down of device

Too high value currently may result in occasional race problem with
device deactivation.

- - - - -
e3cee67d by Zdenek Kabelac at 2023-10-02T14:25:52+02:00
tests: reiserfs needs fsadm

With plain -r we currenly issue an error message.

- - - - -
ffaff7af by Zdenek Kabelac at 2023-10-02T14:25:52+02:00
tests: better handling of system dir

Use more consistenly location of etc dir in tests.
Read value of etc dir via lvm cmd.

- - - - -
80899f70 by Zdenek Kabelac at 2023-10-03T00:00:01+02:00
tests: runner compatible with older g++

Avoid using some constructs available with newer C++ only.
Moving timing into to journal instead of list file.

- - - - -
19df4510 by Zdenek Kabelac at 2023-10-03T00:01:34+02:00
tests: faster creation of 200 PVs

Use already existing optmized aux version

- - - - -
3c70c243 by Zdenek Kabelac at 2023-10-03T00:02:02+02:00
tests: aux use dmsetup concise

A bit faster creation of multiple devices with dmsetup --concise.
Also solves the &#39;cookies&#39; handling.

- - - - -
36bccbc4 by Zdenek Kabelac at 2023-10-03T00:02:46+02:00
tests: skip some tests on valgrind run

Skip some tests that takes too much time with valgrind pass.

- - - - -
a540b3f1 by Zdenek Kabelac at 2023-10-03T00:02:46+02:00
make: generate

- - - - -
13bf42b8 by Zdenek Kabelac at 2023-10-03T01:58:23+02:00
tests: restore fsync for runner

Restore fsync() call For more accurate tracking by buildbot.
Try different rather tricky way of static_cast to use
already opened FD instead of seperate open(),fsync(),close().

It&#39;s pretty strange there is no way to enforce fsync() for
C++ iostreams.  Flush() is actully not equal.

- - - - -
d01e9de8 by Zdenek Kabelac at 2023-10-03T02:01:29+02:00
tests: add RT_LIBS for older g++

- - - - -
6f520916 by Zdenek Kabelac at 2023-10-03T02:01:29+02:00
tests: give dmeventd some time to restart

We need to wait for a new dmeventd as fork new daemon from bash.

- - - - -
48fd6d6d by Zdenek Kabelac at 2023-10-03T12:46:32+02:00
tests: restore old fsync method

New code isn&#39;t portable across wider range of c++ compilers.

- - - - -
c818f3da by Zdenek Kabelac at 2023-10-03T12:46:32+02:00
tests: give some more time to die

VMs are not top performers here...

- - - - -
0e8c631f by Zdenek Kabelac at 2023-10-03T12:59:38+02:00
tests: old g++ needs explicit cast

- - - - -
cf46f4ba by Zdenek Kabelac at 2023-10-03T21:30:22+02:00
filters: sysfs use device_id_sysfs_dir

This is mainly useful in internal testing - but keep sysfs dir also
passed to filter.
Also drop use of static variable within sysfs filter and base whole
config at creation time.

- - - - -
8f61a127 by Zdenek Kabelac at 2023-10-03T21:32:12+02:00
tests: fix reader for runner

Since we now push more data into journal, parser reading this file
for --continue mode need to be adapted.
Also properly align batch mode with &#39;.&#39; for max test length name.

- - - - -
4edaa9fd by Zdenek Kabelac at 2023-10-04T22:03:56+02:00
filters: leave device_id_sysfs_dir only for device_id

Do not use filters for sysfs with device_id.

- - - - -
e72e130e by Zdenek Kabelac at 2023-10-04T22:05:22+02:00
tests: convert to heredoc string

Multi-line echo command are problemat across variety of bash version
and may have produce shorter results.
Convert to stable heredoc string with &#39;tab&#39; skipping &lt;&lt;- for better
formating.

- - - - -
e3adccb5 by Zdenek Kabelac at 2023-10-04T22:05:22+02:00
tests: retry removal

After umout we may race with system udevd rule - so
just retry once again after 1s sleep - that should be
enough - otherwise we would need some loop here...

- - - - -
470f1058 by Zdenek Kabelac at 2023-10-04T23:58:54+02:00
tests: better coredump lookup

Some bash version may have problem with contruct:
done &lt; &lt;(

Replace it with array reading.

- - - - -
b80404f2 by Zdenek Kabelac at 2023-10-04T23:58:54+02:00
tests: utils use read without slash mangling

Do not use backslash as escape character for path.

- - - - -
ede63b50 by Zdenek Kabelac at 2023-10-05T00:03:30+02:00
tests: more complex check for resize of reiserfs

Detection of how the command is supposed to behave actually depends on
the configure.h compilation and whether binary is compiled with
HAVE_BLKID_SUBLKS_FSINFO.

This makes it somewhat complicated in a way how to recognize which
behavior is expected.

Currently we can eventually recognize by checking error output
of some &#39;random&#39; lvresize command and see if the --fs checksize is
actually recognized and rejected.  If this changes - test needs
to be updated.

- - - - -
bccfd92f by Zdenek Kabelac at 2023-10-05T01:11:54+02:00
tests: previous patch wrongly replaced tab

Tab overwrote first char instead of insert.
Actually it should be a single function.

- - - - -
1901a47d by David Teigland at 2023-10-05T15:33:55-05:00
device_id: fix conditions for device_ids_refresh

Fix commit 847f1dd99cb74
&quot;device_id: rewrite validation of devname entries&quot;

which began calling device_ids_refresh() in cases where it
was unnecessary, leading to extra PV searches and warnings.
Specifically, a command like &quot;lvs &lt;vg&gt;&quot; would use the hints
file to scan only devices for the named VG.  This means that
scanning other PVs would be skipped, and device IDs of those
PVs could not be validated because there are no PVID values
to verify.  This missing info would cause messages about
the missing info, and would cause device_ids_refresh to
search for the PVs that had been intentionally skipped.

- - - - -
44f86d38 by Zdenek Kabelac at 2023-10-06T10:50:26+02:00
debug: fix message severity levels

Add some missing WARNS and correct some severity levels.

- - - - -
37329e41 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: add delay to let dmevent initalize

There is short time period needed to fully initilize dmeventd and
handle &#39;kill&#39; signal.

- - - - -
f5512315 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: ignore failure from stop

- - - - -
2c374203 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: skip test if the memory cannot be allocated in kernel

- - - - -
f960fe05 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: delay_dev to slowdown pvmove

throtling mirror device is becoming useless with faster CPUS,
as way to many data can be transferred before throttling steps-in.
So prefer using  dm-delay for test and keep throttling as fallback.

- - - - -
25a87ea1 by David Teigland at 2023-10-06T12:24:34-05:00
device_id: fix lvmdevices update segfault

>From commit 1901a47df12
&quot;device_id: fix conditions for device_ids_refresh&quot;

- - - - -
f20be398 by David Teigland at 2023-10-10T11:46:21-05:00
device_id: refresh devname idnames if any are not found

Search for a PV on other devices if it&#39;s a devname entry
and the name doesn&#39;t exist on the system.  This restores
code that should not have been removed in commit 1901a47df
&quot;device_id: fix conditions for device_ids_refresh&quot;

- - - - -
63b469c1 by David Teigland at 2023-10-10T11:47:29-05:00
device_id: fix hints with device ids

Fix some interactions between device IDs and hints.  Hints
may limit the scanned devices which should not always trigger
a search for the PVs that were intentionally not scanned.
Hints should also be invalidated if they contain a device
that&#39;s become excluded by an internal filter such as the
device_id filter.

- - - - -
25ef7a7b by Lennart Poettering at 2023-10-11T15:35:33+02:00
_create_and_load_v4: propagate ioctl errors back to caller

When setting up dm-verity devices with signed root hashes it is very
useful to have a recognizable error code when a key is not present in
the kernel keyring. Turns out the kernel actually returns ENOKEY in that
case, but this gets lost in libdevmapper.

This fixes this: in _create_and_load_v4() it copies the error code from
the ioctl from the sub-tasks back to the main task field on failure.

This is not enough to make libcryptsetup actually propagate the ENOKEY
correctly, that also needs a patch to libcryptsetup, but this is part of
the puzzle.

- - - - -
eda99fc3 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Clean up group struct in _stats_create_group() error path

Fix a double free in the error path from _stats_create_group() by
clearing the group struct embedded in the dm_stats handle before
returning:

    device-mapper: message ioctl on  (253:0) failed: Invalid argument
    Could not create regions from file /var/tmp/File With Spaces.
    free(): double free detected in tcache 2
    Aborted (core dumped)

- - - - -
f0fd03b1 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: use correct value for precise in _stats_create_file()

- - - - -
ac41deee by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Rename _stats_set_aux() argument

The aux_data argument of _stats_set_aux() is the user-defined data
to be stored with the stats region. Rename the argument to better
reflect this.

- - - - -
33931431 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Refactor _stats_parse_list_region()

Refactor the function that parses regions from @stats_list data to
separate the parsing of variable string data from the fixed parts
of the @stats_list response.

- - - - -
7d8981dd by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: support group aliases with embedded whitespace

Creating a group with a name that contains whitespace causes an error in
the @stats_set_aux message:

device-mapper: message ioctl on  (253:0) failed: Invalid argument
Could not create regions from file /var/tmp/File With Spaces.

Fix this by quoting the group alias and backslash escaping any
embedded space characters.

- - - - -
9aa47f97 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Quote path value in --filemap debug messages

Improves readability of debugging output when file paths contain
whitespace.

- - - - -
995c7b50 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Add more dmstats integration tests

Add new tests for filemap, group/ungroup, histograms, precise timestamps
and userdata.

- - - - -
0ff027ae by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: only generate aux data separator if group tag is defined

Fix a bug in _stats_set_aux() that causes bogus data to appear
in the &#39;userdata&#39; field of stats reports when previously grouped
regions are ungrouped:

/var/tmp/File With Spaces: Created new group with 1 region(s) as group ID 0.

Removed group ID 0 on fedora-root

Name             GrpID RgID ObjType RgStart RgSize  #Areas ArSize  ProgID  UserData
fedora-root          -    0 region    6.39g 100.00m      1 100.00m dmstats #-
                                                                           ^^
This is the aux_data separator character followed by empty user data.
The _stats_set_aux() function should only emit the separator if
there is a valid group descriptor for the region.

- - - - -
fb124f08 by Zdenek Kabelac at 2023-10-13T14:24:49+02:00
device_mapper: pair with libdm _create_and_load_v4

Apply same enhancement also for internal device mapper library
from the commit: 25ef7a7b1a876f491bd361369423d7309358f6c1.

- - - - -
dc8837f0 by Adam Joseph at 2023-10-13T14:25:02+02:00
configure.ac: handle --disable-shared flag

Since LVM 2.02 it appears that compiling LVM on a platform which
lacks a shared library linker/loader will fail to produce any
binaries (dmsetup, lvm2, etc).

Adds support for the standard --disable-shared flag, and
use it to disable attempts at building shared libraries.

Modified-by: zkabelac

- - - - -
48fd9fbd by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
configure.ac: support for static linking

Introduce couple configure options:

--without-blkid
--without-systemd
--without-udev

These can be useful for build with --disable-shared
where those libraries are often distibuted without
their static libraries.

However such compiled static binaries then have limitted usage.

- - - - -
f117d47f by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
configure.ac: version checking for new dmpd tools

New rust version of thin_check returns now also binary name in version,
so adapt the version checking to handle this variant.

- - - - -
627535f3 by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: use function to restart dmeventd

Move restart to single function.

- - - - -
53da6464 by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: fail tests when machine have suspended devs

If the machine has suspended devices present in the DM table,
it&#39;s better to fail the test.

- - - - -
061c008e by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: some minor enhancement of udev test

Reduce pgrep usage.

- - - - -
be2b3d5a by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: increase delay

- - - - -
1605d39b by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: comment about version checking to aux.sh

If there would be futher version checking needed,
make a notice there are now two -V formats.

- - - - -
9fa36441 by Zdenek Kabelac at 2023-10-13T14:33:56+02:00
tests: skip for missing mkfs.xfs

- - - - -
8b8b8ac1 by Zdenek Kabelac at 2023-10-13T14:33:56+02:00
configure: update

- - - - -
0b11b08b by Zdenek Kabelac at 2023-10-13T15:00:55+02:00
tests: handle empty table better

- - - - -
0bbbe083 by Zdenek Kabelac at 2023-10-13T16:04:25+02:00
dmfilemapd: ensure program_id is initialized

Assing program_id before return 1,
and also stay C99 compatible with size_t declaration.

- - - - -
b1624753 by Zdenek Kabelac at 2023-10-13T16:34:48+02:00
makefiles: fix missing libs

Recent commit  dc8837f07982663add6c1f4d87fb79fa9b6c8857
became actually to strict - we always want to build lib.a files.

- - - - -
85c76293 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
libdm: versionion symbol for enhanced dm_task_run

When new app links with current dm_task_run() that propagates ioctl()
errno - ensure it will not be usable with older version without this
supported feature.

- - - - -
46eeb62b by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
pool: fix recalculate of pool chunk_size

Before checking seg_type of the first area, check there is
some existing area.
Since we now support error and zero segtypes, these do not have
any PV area present.

- - - - -
afe1b2be by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
debug: initialize empty string

- - - - -
dd7663d2 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
configure.ac: enhancemetns

Simplify configuration with enabling options:
- For --enable-dmeventd automatically --enable-cmdlib.
- For --enable-dbus-service auto --enable-notify-dbus.

Fix check linux/fiemap.h for dmfilemapd.

- - - - -
0627716f by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
configure: update

- - - - -
43020cc4 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
WHATS_NEW{_DM}: update

- - - - -
9668d40d by Zdenek Kabelac at 2023-10-14T23:10:21+02:00
resize: reduce without prompt for  no-fs case

Apply the same logic for &#39;lvreduce&#39; which exists for newer
systems (compiled with HAVE_BLKID_SUBLKS_FSINFO)
also for older systems for one very common practical case where
the active LV does not have any blkid known signature/filesystem.

New variant recognized this situation and allowed to proceed
without requesting a prompt, while the older variant always
requested confirmation prompt.

With this patch command now works equily for both variants
for &#39;active LV&#39; without signature and allows to reduce LV
without prompting.

- - - - -
6afaaca2 by Zdenek Kabelac at 2023-10-14T23:12:57+02:00
cov: enusure pointer to idname exists

- - - - -
e8e5e6ee by Zdenek Kabelac at 2023-10-14T23:12:57+02:00
cov: check next_get token exists

- - - - -
c6efab01 by Zdenek Kabelac at 2023-10-14T23:12:57+02:00
cov: avoid resoure leaks on error path

- - - - -
26766dcf by Zdenek Kabelac at 2023-10-14T23:12:57+02:00
tests: aux add have_fsinfo

Add function to detect whether lvm2 was compiled with
blkid.h with BLKID_SUBLKS_FSINFO

Currently it can be detected by support of &#39;--fs checksize&#39;.

- - - - -
1a67bfe3 by Zdenek Kabelac at 2023-10-14T23:13:46+02:00
tests: extend the usability for older systems

Extend the test a bit futher so we can keep logic of resize
working similarly well for older and newer systems.

Test uses new &#39;aux have_fsinfo&#39;function to regnize compiled
version of lvm.

- - - - -
d2d8d0ab by Zdenek Kabelac at 2023-10-14T23:14:26+02:00
tests: io stream class saver

Restore io stream when changed by modifiers.
Also simplify getenv access.

- - - - -
5cc54458 by Zdenek Kabelac at 2023-10-14T23:37:38+02:00
tests: old way to disable copy contructor

Mark them private.

- - - - -
63885da5 by Zdenek Kabelac at 2023-10-15T14:42:14+02:00
tests: shorting batch line output

- - - - -
d5e58768 by Zdenek Kabelac at 2023-10-15T14:43:13+02:00
tests: check for blkid

When libblkid is not present (older systems) we can&#39;t use new -fs tests at
all so skip these tests.

- - - - -
dfaa8912 by Zdenek Kabelac at 2023-10-15T19:51:43+02:00
tests: fsck with yes

Fsck may need to update metadata even after clean unmount.

- - - - -
098bc780 by Zdenek Kabelac at 2023-10-15T21:48:22+02:00
tests: better synchronization

- - - - -
f55dc300 by Zdenek Kabelac at 2023-10-15T21:48:22+02:00
tests: simplify line counting

No need for pipes

- - - - -
d12e843e by Zdenek Kabelac at 2023-10-16T00:11:35+02:00
tests: aux mdadm_assemble skip path

If the old mdadm fails to assembly array due to its internal buggy logic
skip the test instead of failure.

- - - - -
e6c6713a by David Teigland at 2023-10-16T14:13:27-05:00
hints: correct fix for hints with device ids

Fixes commit 63b469c1609fe5d3395b7757eebaf35a4a77ea7a
&quot;device_id: fix hints with device ids&quot;

It&#39;s not correct for internal filtering to be a factor
in validating the set of devs that are the basis for hints.

Instead, look for inconsistencies between a hint entry and
the corresponding devices file entry.

- - - - -
d8d4260d by David Teigland at 2023-10-16T15:12:12-05:00
device_id: improve handling of non-standard wwid prefixes

- - - - -
a8368721 by David Teigland at 2023-10-16T15:21:22-05:00
device_id: accept wwids containing QEMU HARDDISK

A wwid may be useful even when it contains the string
&quot;QEMU HARDDISK&quot;, so allow these to be used.

- - - - -
be9a64e6 by David Teigland at 2023-10-16T15:40:11-05:00
device_id: make dmeventd use system.devices by default

When no dmeventd.devices exists, make it use system.devices
rather than no devices file at all.

- - - - -
7e017abb by Zdenek Kabelac at 2023-10-17T16:48:50+02:00
make: generate

- - - - -
493af2bb by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
lvm: fix reporting path with HOME envvar

When envvar HOME is not present we were using invalid path with (null).

- - - - -
cb2873ba by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
tests: ensure file is removed

Make sure there are no previous loop results.

- - - - -
249446e0 by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
tests: avoid busy looping

While waiting for the change, don&#39;t busy loop on CPU.
TODO: fix missing notification about device removal.

- - - - -
d77eed47 by Marian Csontos at 2023-10-17T19:52:23+02:00
spec: Fix spec file to work with mock

- missing BuildRequires

diff --git a/spec/source.inc b/spec/source.inc
index 7b44ef152..b04c500a2 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -12,8 +12,8 @@
 %global enable_lvmlockd 1
 %global enable_lvmpolld 1
 %global enable_dmfilemapd 0
-#%global enable_lvmlockd_dlm 0
-#%global enable_lvmlockd_sanlock 0
+#%%global enable_lvmlockd_dlm 0
+#%%global enable_lvmlockd_sanlock 0

 %if %{enable_udev}
 %service lvmpolld 1
@@ -43,7 +43,8 @@
 %with writecache internal
 %with integrity internal

-%global buildreq_udev systemd-devel
+# NOTE: Required by fedora 38+, maybe older
+%global buildreq_udev systemd-devel, systemd-units
 %global req_udev udev &gt;= 181-1

@@ -60,15 +61,12 @@
  %global sanlock_version 3.3.0-1
  %global enable_lvmlockd_dlm 1
  %global enable_lvmlockd_sanlock 1
+ # FIXME: Check these conditions against RHEL builds!
  %if %{rhel}
-  %ifarch i686 x86_64 s390x
-   %global buildreq_lvmlockd_dlm dlm-devel &gt;= %{dlm_version}
-  %else
+  %ifnarch i686 x86_64 s390x
    %global enable_lvmlockd_dlm 0
   %endif
-  %ifarch x86_64 ppc64le ppc64 aarch64
-   %global buildreq_lvmlockd_sanlock sanlock-devel &gt;= %{sanlock_version}
-  %else
+  %ifnarch x86_64 ppc64le ppc64 aarch64
    %global enable_lvmlockd_sanlock 0
   %endif
  %endif
@@ -78,6 +76,12 @@
   %global enable_lvmlockd_dlm 1
  %endif
 %endif
+%if 0%{enable_lvmlockd_dlm}
+ %global buildreq_lvmlockd_dlm dlm-devel &gt;= %{dlm_version}
+%endif
+%if 0%{enable_lvmlockd_sanlock}
+ %global buildreq_lvmlockd_sanlock sanlock-devel &gt;= %{sanlock_version}
+%endif

 ##############################################################

@@ -164,6 +168,11 @@ Source92: build.inc
 Source93: packages.inc
 Source94: macros.inc

+BuildRequires: make
+BuildRequires: gcc
+%if %{enable_testsuite}
+BuildRequires: gcc-c++
+%endif
 BuildRequires: libselinux-devel &gt;= 1.30.19-4, libsepol-devel
 BuildRequires: ncurses-devel
 %if %{enable_readline}
@@ -174,6 +183,9 @@ BuildRequires: libedit-devel
 %endif
 BuildRequires: module-init-tools
 BuildRequires: pkgconfig
+# TODO: Should these be conditional?
+BuildRequires: libaio-devel
+BuildRequires: libblkid-devel

 # Expands to nothing unless at least 2 arguments are given
 %define maybe() \
@@ -189,6 +201,8 @@ BuildRequires: pkgconfig
 %maybe BuildRequires: %{?buildreq_lvmlockd_sanlock}
 %maybe BuildRequires: %{?buildreq_python3_devel}
 %maybe BuildRequires: %{?buildreq_python3_setuptools}
+%maybe BuildRequires: %{?buildreq_python3_dbus}
+%maybe BuildRequires: %{?buildreq_python3_pyudev}

 %description
 LVM2 includes all of the support for handling read/write operations on

- - - - -
3c68cbab by Marian Csontos at 2023-10-17T19:52:23+02:00
CI: Adjust lvm.conf for testing

- - - - -
bf400dfa by Marian Csontos at 2023-10-17T19:52:23+02:00
spec: Modify spec to work with packit

packit is searching Release tag in spec file.

- - - - -
ee9444e0 by Marian Csontos at 2023-10-17T19:52:23+02:00
spec: Add fedora lvm2.spec for packit

- - - - -
c06e1655 by Marian Csontos at 2023-10-17T19:52:23+02:00
packit: Add packit configuration

- - - - -


30 changed files:

- .gitignore
- + .gitlab-ci.yml
- + .packit.yaml
- Makefile.in
- README
- VERSION
- VERSION_DM
- WHATS_NEW
- WHATS_NEW_DM
- autoconf/py-compile
- conf/example.conf.in
- conf/vdo-small.profile
- configure
- configure.ac
- daemons/cmirrord/cluster.c
- daemons/cmirrord/functions.c
- daemons/cmirrord/local.c
- daemons/dmeventd/dmeventd.c
- daemons/dmeventd/libdevmapper-event.c
- daemons/lvmdbusd/Makefile.in
- daemons/lvmdbusd/lvm_shell_proxy.py.in
- daemons/lvmdbusd/utils.py
- daemons/lvmlockd/lvmlockd-core.c
- daemons/lvmlockd/lvmlockd-dlm.c
- daemons/lvmlockd/lvmlockd-internal.h
- daemons/lvmpolld/lvmpolld-data-utils.h
- device_mapper/all.h
- device_mapper/ioctl/libdm-iface.c
- device_mapper/libdm-common.c
- device_mapper/libdm-report.c


The diff was not included because it is too large.


View it on GitLab: https://gitlab.com/csonto/lvm2/-/compare/54f0268ba41409880cbe931dce5adcb680c39a09...c06e1655525be4622e98260f1b202821ab0d0996

-- 
View it on GitLab: https://gitlab.com/csonto/lvm2/-/compare/54f0268ba41409880cbe931dce5adcb680c39a09...c06e1655525be4622e98260f1b202821ab0d0996
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231017/27acf1bb/attachment-0001.htm>
