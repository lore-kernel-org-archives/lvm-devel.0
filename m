From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 3 Dec 2009 01:25:22 +0000
Subject: [PATCH 04/23] Export outsz() and outhnt() for modules
In-Reply-To: <1259581043-15308-5-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
Message-ID: <20091203012522.GR22702@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Nov 30, 2009 at 12:37:04PM +0100, Zdenek Kabelac wrote:
> Adding macro outsz() for out_size() and outhnt() for out_hint()
> that checks for error in a similar way as outf() does for out_text()

> +#define outsz(args...) do {if (!out_size(args)) return_0;} while (0)
> +#define outhnt(args...) do {if (!out_hint(args)) return_0;} while (0)
>  #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
>  #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
  
But outsz and outhnt are ugly, so if we can't think of better names,
let's at least add another patch to swap over all 4 names so the
exported versions are the 'nice' ones.

 #define out_newline(f) do {if (!outnl(f)) return_0;} while (0)

Alasdair


