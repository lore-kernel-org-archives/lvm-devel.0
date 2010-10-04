From: Milan Broz <mbroz@redhat.com>
Date: Mon, 04 Oct 2010 20:54:19 +0200
Subject: [PATCH] Restrict lvm1 partial mode.
In-Reply-To: <8762xh50zj.fsf@twilight.int.mornfall.net.>
References: <1286210927-10607-1-git-send-email-mbroz@redhat.com>
	<8762xh50zj.fsf@twilight.int.mornfall.net.>
Message-ID: <4CAA22DB.4080703@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/04/2010 07:20 PM, Petr Rockai wrote:
> Does what the comment says... would the result be a bit less confusing
> though if it said
> 
> memcpy(&pvl->pv->id.uuid, "missing_", 8);
> 
> instead? I know, a nitpick.

negative. Because we do not allow "_" in UUID :-)

m.


