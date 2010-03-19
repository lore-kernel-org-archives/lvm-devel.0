From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Mar 2010 16:08:07 -0400
Subject: Don't allow resizing of internal logical volumes
In-Reply-To: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
Message-ID: <20100319200807.GC7345@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 18 2010 at  7:53pm -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> This patch prevents resizing of internal volumes.
> 
> BTW.: do you think that *-shared should be treated as a reseved logical 
> volume name?
> It is really the internal volume name, but the potential problem with it 
> is that there may be some systems with existing names *-shared, and 
> reserving the name breaks those systems.
> 
> Mikulas
> 
> ---
> 
> Don't allow resizing of internal logical volumes.
> 
> This patch prevents lvresize from being able to resize internal LVs: mirror
> legs (*_mimage_*), mirror log (*_mlog), snapshot placeholder LVs (snapshot*)
> and others. Resizing these would leads to unexpected metadata and sometimes
> crashes (in case of growing snapshot*).
> 
> Note that test for VISIBLE_LV is not sufficient because snapshot0 volumes
> have the VISIBLE_LV flag set. So we test the name instead of the flags.

OK, but snapshotX volumes are part of the LVM2 snapshot "fiction".  They
never get exposed to the end user (even with lvs -a).  Only the user
facing snapshot LV name gets exposed:
# lvs test/snapshot0
  One or more specified logical volume(s) not found.
# lvs test/testlv1_snap
  LV           VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
  testlv1_snap test swi-a- 4.00g testlv1                               

As such we shouldn't have to worry about the user attempting to resize
the hidden snapshotX volume.  Am I still missing something?

That said the LVM2 snapshot "fiction" is really unfortunate.  Keeps
getting in the way (mostly a mental barrier for me; quite unnatural).

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> ---
>  tools/lvresize.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> Index: LVM2/tools/lvresize.c
> ===================================================================
> --- LVM2.orig/tools/lvresize.c	2010-03-19 00:25:31.000000000 +0100
> +++ LVM2/tools/lvresize.c	2010-03-19 00:44:52.000000000 +0100
> @@ -323,6 +323,11 @@ static int _lvresize(struct cmd_context 
>  
>  	lv = lvl->lv;
>  
> +	if (is_reserved_lvname(lv->name)) {
> +		log_error("Can't resize internal logical volume %s", lv->name);
> +		return ECMD_FAILED;
> +	}
> +
>  	if (lv->status & LOCKED) {
>  		log_error("Can't resize locked LV %s", lv->name);
>  		return ECMD_FAILED;

Given my recent ACCESS_HIDDEN_LV patch here:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.63/lvm-shared-add-ACCESS_HIDDEN_LV-flag.patch

I was thinking we'd just have something like this:

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 849fd2e..f08be60 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -323,6 +323,11 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	lv = lvl->lv;
 
+	if (!lv_is_visible(lv) && !lv_is_accessible_hidden(lv)) {
+		log_error("Can't resize internal logical volume %s", lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't resize locked LV %s", lv->name);
 		return ECMD_FAILED;


