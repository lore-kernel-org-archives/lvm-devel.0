From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 13 Oct 2009 16:20:42 -0500
Subject: [PATCH 0 of 2] LVM: Split mirror capability
Message-ID: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding code to allow users to split legs off of a mirror wasn't all that
hard.  However, I could use some help regarding the nature of the
arguments that should be used to invoke this action.

The following patches introduce a new (horrible) argument '--split' to
lvconvert that signals the intent to split and keep a desired leg of a
mirror.  Example run:

[root at bp-01 ~]# lvcreate -m2 -L 500M -n lv vg
  Logical volume "lv" created
[root at bp-01 ~]# lvs -a -o name,copy_percent,devices
  LV            Copy%  Devices
  LogVol00             /dev/sda2(0)
  LogVol01             /dev/sda2(4451)
  lv            100.00 lv_mimage_0(0),lv_mimage_1(0),lv_mimage_2(0)
  [lv_mimage_0]        /dev/sdb1(0)
  [lv_mimage_1]        /dev/sdc1(0)
  [lv_mimage_2]        /dev/sdd1(0)
  [lv_mlog]            /dev/sdi1(0)
[root at bp-01 ~]# lvconvert -m1 --split vg/lv /dev/sdc1
  Logical volume lv converted.
[root at bp-01 ~]# lvs
  LV          VG         Attr   LSize   Origin Snap%  Move Log     Copy%  Convert
  LogVol00    VolGroup00 -wi-ao 139.09g
  LogVol01    VolGroup00 -wi-ao   9.81g
  lv          vg         mwi-a- 500.00m                    lv_mlog 100.00
  lv_mimage_1 vg         -wi-a- 500.00m

You can see from the above that I went as far as to specify the leg I
wanted split off.

Aside from the new '--split' argument not being very good, we also end
up with a new logical volume named, 'lv_mimage_1', which also isn't very
good.  Should I change the name via s/_mimage_1/-copy-%d/, or should I
allow the name to be specified (or left alone)?

Here is the current syntax and some others I have thought of:

# New '--split' argument.
# This is suppose to give the user the ability to signify a split
# of the mirror, rather than a reduction/increase in mirror images.
# However, something like '--keep_images' might better signify that
# although we are reducing the number of mirror legs, we want to
# have them presented rather than removed.
prompt> lvconvert -m <n> --split vg/lv <removable device(s)>

# New '--splitmirror <n>' argument
# Replaces '-m <n> --split', and rather than specifying the number
# of legs you want remaining in the mirror when finished, you specify
# the number of legs you want split off.
#
# BTW, you can only split off one leg at a time right now, but I
# don't see a reason why we couldn't split a 4-way mirror into
# 2 2-way mirrors at some point in the future.  (Being able to
# specify the removable devices also allows us to choose every
# other device if we chose to.)
prompt> lvconvert --splitmirror 1 vg/lv <removable device(s)>

Please added better ideas if you have them... I am leaning toward the
second example (even though I implemented the 1st in the patches).

Concerning the naming of the newly split off device, we could use the
'-n <name>' argument.  If unspecified, we would have to choose some
default.

 brassow


