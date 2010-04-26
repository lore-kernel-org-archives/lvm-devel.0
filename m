From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:26:51 +0100
Subject: [PATCH 08/22] Replicator: extend volume_group with list of VGs
In-Reply-To: <bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426142651.GP23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:36PM +0200, Zdenek Kabelac wrote:
> Add linked list of opened VGs. List keeps the information
> about needed and locked and opened VGs for replicator target.
> Also add missing_vgs status information for quick check and
> also for possible continuos process_each_lv() where we need
> to detect whether failure has been caused by missing VG or
> some other reason.
 
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index 6d40365..9c73dba 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -250,6 +250,10 @@ struct volume_group {
> +        /* List of wanted/locked and opened VGs */
> +	struct dm_list vgs;
> +	uint32_t missing_vgs;

Can we think up more-specific names?

vg->vgs isn't very informative.

Alasdair


