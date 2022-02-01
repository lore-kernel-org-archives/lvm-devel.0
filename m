From: Martin Wilck <mwilck@suse.com>
Date: Tue, 01 Feb 2022 12:11:44 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <20220201105507.rq7rll4qjhxonzu6@alatyr-rpi.brq.redhat.com>
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
	<20220201105507.rq7rll4qjhxonzu6@alatyr-rpi.brq.redhat.com>
Message-ID: <5eda612b861cf911319087c4c5af8bb6815e1928.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2022-02-01 at 11:55 +0100, Peter Rajnoha wrote:
> 
> Thing is, we only restore DM_* values in 10-dm.rules, but we need to
> do
> the same for blkid values. That would be a patch like this on top of
> yours:

Right. For those devices I'm mainly concerned about, this is done in
11-dm-mpath.rules and 11-dm-parts.rules (both part of multipath-tools).

https://github.com/opensvc/multipath-tools/blob/master/multipath/11-dm-mpath.rules
https://github.com/opensvc/multipath-tools/blob/master/kpartx/dm-parts.rules

If you want the same functionality for generic dm devices, you need
these import statements in the generic code as well.

I should have added the imports right away, I might have been causing
less confusion. But I thought I'd cause less potential for regressions
this way, as all the SYMLINK+=... rules first test whether the related
properties are non-empty.

> 
> ?udev/13-dm-disk.rules.in | 14 ++++++++++++--
> ?1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
> index 5cc08121e..9b1a0b562 100644
> --- a/udev/13-dm-disk.rules.in
> +++ b/udev/13-dm-disk.rules.in
> @@ -17,12 +17,22 @@ ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1",
> GOTO="dm_end"
> ?SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
> ?ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
> ?
> -ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1",
> GOTO="dm_link"
> -ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1",
> GOTO="dm_link"
> +ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1",
> GOTO="dm_blkid_restore"
> +ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1",
> GOTO="dm_blkid_restore"
> ?ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
> ?ENV{DM_NOSCAN}=="1", GOTO="dm_watch"
> ?
> ?(BLKID_RULE)
> +GOTO="dm_link"
> +
> +LABEL="dm_blkid_restore"
> +IMPORT{db}="ID_FS_USAGE"
> +IMPORT{db}="ID_FS_UUID_ENC"
> +IMPORT{db}="ID_FS_LABEL_ENC"
> +IMPORT{db}="ID_PART_ENTRY_UUID"
> +IMPORT{db}="ID_PART_ENTRY_SCHEME"
> +IMPORT{db}="ID_PART_ENTRY_NAME"
> +IMPORT{db}="ID_PART_GPT_AUTO_ROOT"

This looks ok. The list of variables is a little different in the
multipath rules files. Anyway, the only properties that matter are
those for which we're going to create symlinks for. 

In general, the approach of doing this here is somewhat fragile - when
udev's blkid changes, the list of determined / required device
properties might change as well. It'd be optimal to move this logic
into udev proper, into the generic rules that handle storage device
naming (60-persistent-storage.rules). Then all we'd need to do in the
dm rules would be to set a flag telling udev that blkid shouldn't be
called because it might hang, and perhaps another one to tell that it's
OK to import the properties from the db instead.

Regards
Martin



