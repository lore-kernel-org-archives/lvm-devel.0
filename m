From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Mar 2011 16:45:34 +0100
Subject: [PATCH] dmeventd protocol versioning mechanism
In-Reply-To: <87pqpkmqu0.fsf@twilight.int.mornfall.net.>
References: <877hbunlu9.fsf@twilight.int.mornfall.net.>	<4D875CF9.5020100@redhat.com>
	<87pqpkmqu0.fsf@twilight.int.mornfall.net.>
Message-ID: <4D87729E.40202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/21/2011 04:32 PM, Petr Rockai wrote:
> it is not (safe), on the other hand there's code in other places in
> libdevmapper-event that assumes correctly formatted messages and will
> segfault otherwise.

Reminds me famous last words: "dmeventd cannot segfault" :-)

We should be more careful at least in new code, it should not hurt much
to reject garbage on input.

Milan


