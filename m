From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 14 Dec 2010 11:59:16 +0000
Subject: [PATCH] vg_validate support for pvmove LVs (BZ 662669)
In-Reply-To: <87ipyx74dd.fsf@twilight.int.mornfall.net.>
References: <87ipyx74dd.fsf@twilight.int.mornfall.net.>
Message-ID: <20101214115915.GA9304@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 13, 2010 at 10:24:46PM +0100, Peter Rockai wrote:
> +					log_error(INTERNAL_ERROR
> +						  "Segment %d in %s is not 2-way.",
> +						  loop_counter1, lvl->lv->name);

> +				log_error(INTERNAL_ERROR
> +					  "Segment %d in %s has wrong number of areas: %d.",
> +					  loop_counter1, lvl->lv->name, seg->area_count);

I was going to say 'add pvmove' to the messages, but the LV name is already
going to tell you that.  
Ack.

Alasdair


