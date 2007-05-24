From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 24 May 2007 16:15:50 -0400
Subject: pvdisplay --maps
In-Reply-To: <465553B6.8080803@gmail.com>
References: <465553B6.8080803@gmail.com>
Message-ID: <1180037750.3288.18.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2007-05-24 at 18:58 +1000, David Robinson wrote:
> Patch below adds the -m/--maps option to pvdisplay. Addresses BZ 149814.
> 
>          -m, --maps
>                Display the mapping of physical extents to logical 
> volumes and logical extents.
> 
> Cheers,
> Dave

Thanks - looks good.  Minor comments below.

> diff -urp LVM2.orig/lib/display/display.c LVM2/lib/display/display.c
> --- LVM2.orig/lib/display/display.c	2006-12-01 09:11:40.000000000 +1000
> +++ LVM2/lib/display/display.c	2007-05-24 18:45:13.000000000 +1000
> @@ -258,6 +258,32 @@ void pvdisplay_colons(struct physical_vo
>   	return;
>   }
> 
> +void pvdisplay_segments(struct physical_volume *pv)
> +{
> +        struct pv_segment *seg;
> +
> +        log_print("--- Segments ---");
> +
> +	list_iterate_items(seg, &pv->segments) {
> + 		if (seg->len == pv->pe_count) continue;
> +			log_print("Physical extent %u to %u:",
> +			          seg->pe, seg->pe + seg->len - 1);
> +
> +		if (seg->lvseg) {
> +			log_print("  LV Name\t\t%s%s/%s",
> +			          seg->lvseg->lv->vg->cmd->dev_dir,
> +			          seg->lvseg->lv->vg->name,
> +			          seg->lvseg->lv->name);
> +			log_print("  Logical extents\t%d to %d",
> +			          seg->lvseg->le, seg->lvseg->le +
> +			          seg->lvseg->len - 1);
> +		}
> +        }
> +
> +        log_print(" ");
> +	return;
> +}
> +

Some minor whitespace problems here (mix of tabs / spaces) - will fix.

Also we probably want to display the "Type" of the extents, as well as
"Logical volume" instead of "LV Name", since that more closely matches
the output of lvdisplay.  And an 'else' clause here to explicitly state
"FREE" for PEs that are not allocated.


Index: LVM2/lib/display/display.c
===================================================================
--- LVM2.orig/lib/display/display.c	2007-05-24 15:52:53.000000000 -0400
+++ LVM2/lib/display/display.c	2007-05-24 15:55:56.000000000 -0400
@@ -260,27 +260,31 @@ void pvdisplay_colons(struct physical_vo
 
 void pvdisplay_segments(struct physical_volume *pv)
 {
-        struct pv_segment *seg;
+	struct pv_segment *seg;
 
-        log_print("--- Segments ---");
+	log_print("--- Segments ---");
 
 	list_iterate_items(seg, &pv->segments) {
- 		if (seg->len == pv->pe_count) continue;
-			log_print("Physical extent %u to %u:",
-			          seg->pe, seg->pe + seg->len - 1);
+		if (seg->len == pv->pe_count) continue;
+
+		log_print("Physical extent %u to %u:",
+			  seg->pe, seg->pe + seg->len - 1);
 
 		if (seg->lvseg) {
-			log_print("  LV Name\t\t%s%s/%s",
-			          seg->lvseg->lv->vg->cmd->dev_dir,
-			          seg->lvseg->lv->vg->name,
-			          seg->lvseg->lv->name);
+			log_print("  Type\t\t%s",
+				  seg->lvseg->segtype->ops->name(seg->lvseg));
+			log_print("  Logical volume\t%s%s/%s",
+				  seg->lvseg->lv->vg->cmd->dev_dir,
+				  seg->lvseg->lv->vg->name,
+				  seg->lvseg->lv->name);
 			log_print("  Logical extents\t%d to %d",
-			          seg->lvseg->le, seg->lvseg->le +
-			          seg->lvseg->len - 1);
-		}
-        }
+				  seg->lvseg->le, seg->lvseg->le +
+				  seg->lvseg->len - 1);
+		} else
+			log_print("  FREE");
+	}
 
-        log_print(" ");
+	log_print(" ");
 	return;
 }
 



