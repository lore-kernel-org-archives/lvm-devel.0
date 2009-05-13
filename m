From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 13 May 2009 02:45:27 +0100
Subject: Re: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
In-Reply-To: <20090512191215.29370.qmail@sourceware.org>
References: <20090512191215.29370.qmail@sourceware.org>
Message-ID: <20090513014527.GB10652@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 12, 2009 at 07:12:15PM -0000, mbroz at sourceware.org wrote:
> 	Remove snapshot_count from VG and use function instead.

Ack.

 
> +unsigned snapshot_count(const struct volume_group *vg)
> +{
> +	struct lv_list *lvl;
> +	unsigned lv_count = 0;

snapshot_count:-)

Alasdair


