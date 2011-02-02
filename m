From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 2 Feb 2011 16:43:02 -0600
Subject: [PATCHv3 2 of 2]LVM: allow exclusive snapshots in cluster
In-Reply-To: <20110202195048.GA14956@agk-dp.fab.redhat.com>
References: <1296670066.27798.18.camel@hydrogen.msp.redhat.com>
	<20110202195048.GA14956@agk-dp.fab.redhat.com>
Message-ID: <8AC39555-509F-4418-A1E4-4C1C699C25DE@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Feb 2, 2011, at 1:50 PM, Alasdair G Kergon wrote:

>>
>> B) 'vgchange -ay' returns success on only one node (as mbroz
>> highlighted) when there are snapshots in a cluster because only one  
>> node
>> can activate all the LVs.  The other LVs on the remaining nodes still
>> activate properly.
>
> Bug.
> You may have to query the status afterwards to work out the
> right return code to use or combine the responses from all the nodes
> intelligently to see that exactly one has it active.
> (The node running the command doesn't know what activation filters
> might be set on other nodes, so must send the command to every node
> but expect exactly one to end up with it active.)

Still working on the first item, but this one is addressed with the  
following patch:

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -794,13 +794,11 @@ int lv_is_active_exclusive_locally(struc
         return _lv_is_active(lv, &l, &e) && l && e;
  }

-/*
  int lv_is_active_exclusive_remotely(struct logical_volume *lv)
  {
         int l, e;
         return _lv_is_active(lv, &l, &e) && !l && e;
  }
-*/

  #ifdef DMEVENTD
  static struct dm_event_handler *_create_dm_event_handler(struct  
cmd_context *cmd, const char *dmuuid, const char *dso,
Index: LVM2/lib/activate/activate.h
===================================================================
--- LVM2.orig/lib/activate/activate.h
+++ LVM2/lib/activate/activate.h
@@ -95,6 +95,7 @@ int lvs_in_vg_opened(const struct volume

  int lv_is_active(struct logical_volume *lv);
  int lv_is_active_exclusive_locally(struct logical_volume *lv);
+int lv_is_active_exclusive_remotely(struct logical_volume *lv);

  int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
                        const char *layer, const char *target_type);
Index: LVM2/tools/vgchange.c
===================================================================
--- LVM2.orig/tools/vgchange.c
+++ LVM2/tools/vgchange.c
@@ -115,6 +115,16 @@ static int _activate_lvs_in_vg(struct cm
                     ((lv->status & PVMOVE) ))
                         continue;

+               /*
+                * If the LV is active exclusive remotely,
+                * then ignore it here
+                */
+               if (lv_is_active_exclusive_remotely(lv)) {
+                       log_verbose("%s/%s is exclusively active on"
+                                   " a remote node", vg->name, lv- 
 >name);
+                       continue;
+               }
+
                 expected_count++;

                 if (activate == CHANGE_AN) {


