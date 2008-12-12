From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 00:46:54 +0000
Subject: [PATCH] Use struct cmd_context* as type for lvm2_handle_t with hidden cmd_context. Accessors and mutators have to be used. (lib/lvm2.h)
In-Reply-To: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
Message-ID: <20081212004654.GS24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 05:43:39PM +0100, Thomas Woerner wrote:
> diff --git a/lib/lvm2.h b/lib/lvm2.h
> +void lvm2_destroy(lvm2_handle_t h);

Let's use a longer variable name than 'h' and something unique so we can grep
for it easily.

Apart from that, ACK.

Alasdair
-- 
agk at redhat.com


