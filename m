From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 21 Nov 2009 00:26:55 +0100
Subject: [PATCH 02/15] lvm-merge-metadata
In-Reply-To: <1258756555-14486-3-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
	<1258756555-14486-3-git-send-email-snitzer@redhat.com>
Message-ID: <4B0725BF.3060707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.11.2009 23:35, Mike Snitzer napsal(a):
> From: Mikulas Patocka <mpatocka@redhat.com>
> 
> Add 'SNAPSHOT_MERGE' lv_segment 'status' flag.
> 
> Make 'merging_snapshot' pointer that points from the origin to the
> segment that represents the merging snapshot.
> 
> Import/export 'merging_store' metadata.
> 
> Do not allow creating snapshots while another snapshot is merging.
> Snapshot created in this state would certainly contain invalid data.
> 
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index e9a3d5d..30073d3 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -60,6 +60,7 @@
>  //#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
>  //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
>  #define CONVERTING		0x00400000U	/* LV */
> +#define SNAPSHOT_MERGE		0x00800000U	/* SEG */
>  
>  #define MISSING_PV              0x00800000U	/* PV */

I think reusing these bitfields might lead to unexpected troubles.

Zdenek


