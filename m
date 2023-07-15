From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Sat, 15 Jul 2023 09:06:35 +0000
Subject: [Git][lvmteam/lvm2][main] 10 commits: mm: add libzstd to ignore list
Message-ID: <64b2619b61ec7_28a8a0c989e6@gitlab-sidekiq-low-urgency-cpu-bound-v2-5867f8689f-gbssk.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
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


30 changed files:

- WHATS_NEW
- lib/log/log.c
- lib/mm/memlock.c
- test/lib/aux.sh
- test/shell/devicesfile-basic.sh
- test/shell/devicesfile-devname.sh
- test/shell/devicesfile-serial.sh
- test/shell/duplicate-pvs-md0.sh
- test/shell/duplicate-vgnames.sh
- test/shell/duplicate-vgrename.sh
- test/shell/hints.sh
- test/shell/integrity-dmeventd.sh
- test/shell/integrity-syncaction.sh
- test/shell/lvconvert-cache-abort.sh
- test/shell/lvconvert-raid0_to_raid10.sh
- test/shell/lvconvert-raid1-split-trackchanges.sh
- test/shell/lvconvert-raid10.sh
- test/shell/lvconvert-repair-replace.sh
- test/shell/lvconvert-thin-from-thick.sh
- test/shell/lvconvert-vdo-raid.sh
- test/shell/lvextend-raid.sh
- test/shell/lvm-on-md.sh
- test/shell/lvresize-fs-crypt.sh
- test/shell/pvcreate-operation-md.sh
- test/shell/pvmove-resume-1.sh
- test/shell/pvmove-resume-multiseg.sh
- tools/lvchange.c
- tools/lvconvert.c
- tools/lvmcmdline.c
- tools/lvscan.c


The diff was not included because it is too large.


View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1c60c6785c222b3fed4747ec11ef3aacebc4a680...0670338e0b352490a12a5291a2b571846fb7b09d

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1c60c6785c222b3fed4747ec11ef3aacebc4a680...0670338e0b352490a12a5291a2b571846fb7b09d
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230715/82d4ef01/attachment.htm>
