From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 09 Feb 2009 08:53:45 +0100
Subject: [PATCH] Fix segfault when using vgsplit in stacked environment
Message-ID: <498FE109.6000103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a small patch for segmentation fault in vgsplit while using 
stacked VGs (rh bz 481793). Segfault is caused by null dereference in 
'pv_uses_vg' function that is called to check if a PV uses VG somewhere 
in its construction. In stacked environment, when the LV/VG from lower 
layer is disabled, the PV constructed above does not exist as well and 
so the device value in PV's structure is set to NULL. We should check 
for this NULL value in 'pv_uses_vg' and return immediately if the 
situation occurs.

Peter


diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2bc1db7..4ffd7bb 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1105,6 +1105,9 @@ int pv_uses_vg(struct physical_volume *pv,
  	if (!activation())
  		return 0;

+	if (!pv->dev || !pv->dev->dev)
+		return 1;
+
  	if (!dm_is_dm_major(MAJOR(pv->dev->dev)))
  		return 0;


