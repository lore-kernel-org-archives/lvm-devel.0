From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 1 Feb 2022 11:55:07 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <3f7f5039c4529912970f21fe699ad204dfbe5be3.camel@suse.com>
References: <a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
	<aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
	<92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
	<1b20e88f-2714-3c61-73a6-2f34f6a34edc@gmail.com>
	<712b54a06fa1b13f9ac92a00d7b121979c43d31c.camel@suse.com>
	<20220131133354.vfomn5gdlgrhue4g@alatyr-rpi.brq.redhat.com>
	<3f7f5039c4529912970f21fe699ad204dfbe5be3.camel@suse.com>
Message-ID: <20220201105507.rq7rll4qjhxonzu6@alatyr-rpi.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue 01 Feb 2022 09:40, Martin Wilck wrote:
> On Mon, 2022-01-31 at 14:33 +0100, Peter Rajnoha wrote:
> > (just discussed this with Zdenek too)
> > 
> > The patch makes sense to me!
> > 
> > We added all the DM_UDEV_PRIMARY_SOURCE_FLAG and related for exactly
> > such cases where we need to take the existing values already scanned
> > in previous event, main use-case being the trigger at boot. We just
> > didn't cover the 13-dm-disk.rules with the same logic regarding the
> > suspended state to keep the symlinks - I didn't think it would cause
> > issues (because, usually, after suspend, we anticipate incoming
> > resume where the device is scanned again).
> > 
> > But yes, if temporarily losing the symlink causes issues, your patch
> > solves that (Zdenek will push that upstream).
> 
> Thank you very much! It occured to me that if we want to solve my use
> case with minimal risk, we could make the the case in which the
> symlinks are preserved conditional on ACTION=="add" (i.e. true coldplug
> events). Tell me if you'd prefer that, I can re-submit.

I'd keep it for both actions ("add" and "change") because:

  - we won't be creating special case where only "add" is processed in
    13-dm-disk.rules,

  - there's also a chance that someone might call "udevadm trigger
    --action=change" which should also work.

I've just been playing with this change a bit and noticed we forgot to
"IMPORT{db}" the blkid values. I tried this with an fs on top of <dm_dev>
so there should be ID_FS_UUID_END based on which the /dev/disk/by-uuid/<UUID>
should be present:

   1) "udevadm info --name=<dm_dev>"
      (ID_FS_UUID_ENC is there and included in DEVLINKS)

   2) "dmsetup suspend <dm_dev>"

   3) "echo add > /sys/block/<dm_dev>/uevent"
      (to simulate the trigger)

   4) "udevadm info --name=<dm_dev>"
      (ID_FS_UUID_ENV should still be there and included in DEVLINKS)

   5) "dmsetup resume <dm_dev>"
      (ID_FS_UUID_ENV + DEVLINKS still correct)

Thing is, we only restore DM_* values in 10-dm.rules, but we need to do
the same for blkid values. That would be a patch like this on top of yours:

 udev/13-dm-disk.rules.in | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 5cc08121e..9b1a0b562 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -17,12 +17,22 @@ ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
-ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_link"
-ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_link"
+ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_blkid_restore"
+ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_blkid_restore"
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 ENV{DM_NOSCAN}=="1", GOTO="dm_watch"
 
 (BLKID_RULE)
+GOTO="dm_link"
+
+LABEL="dm_blkid_restore"
+IMPORT{db}="ID_FS_USAGE"
+IMPORT{db}="ID_FS_UUID_ENC"
+IMPORT{db}="ID_FS_LABEL_ENC"
+IMPORT{db}="ID_PART_ENTRY_UUID"
+IMPORT{db}="ID_PART_ENTRY_SCHEME"
+IMPORT{db}="ID_PART_ENTRY_NAME"
+IMPORT{db}="ID_PART_GPT_AUTO_ROOT"
 
 LABEL="dm_link"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"


