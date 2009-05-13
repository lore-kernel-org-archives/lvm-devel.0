From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 13 May 2009 13:09:05 +0200
Subject: [PATCH] Add escape sequence for ':' in command's PV list
Message-ID: <4A0AAA51.8040609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this little patch provides an escape sequence in command's PV list
where ':' is also used as a delimiter for extent ranges. To escape
this char, we just double it, so '::' is translated to ':' and ':'
is extent range delimiter.
(BZ #491409)

Peter


diff --git a/tools/toollib.c b/tools/toollib.c
index aa33468..b5a43b5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1095,8 +1095,9 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 	struct dm_list *r;
 	struct pv_list *pvl;
 	struct dm_list tags, arg_pvnames;
-	const char *pvname = NULL;
+	char *pvname = NULL;
 	char *colon, *tagname;
+	char *ptr, *ptr_end;
 	int i;
 
 	/* Build up list of PVs */
@@ -1128,9 +1129,21 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 			continue;
 		}
 
-		pvname = argv[i];
+		ptr = pvname = argv[i];
+		ptr_end = strchr(ptr, '\0');
+		colon = NULL;
 
-		if ((colon = strchr(pvname, ':'))) {
+		while ((ptr = strchr(ptr, ':'))) {
+			if (ptr[1] == ':') {
+				memmove(ptr, ptr + 1, ptr_end - ptr);
+				ptr_end--;
+			}
+			else if (!colon)
+				colon = ptr;
+			ptr++;
+		}
+
+		if (colon) {
 			if (!(pvname = dm_pool_strndup(mem, pvname,
 						    (unsigned) (colon -
 								pvname)))) {


