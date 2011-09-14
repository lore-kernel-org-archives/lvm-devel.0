From: Milan Broz <mbroz@redhat.com>
Date: Wed, 14 Sep 2011 14:26:23 +0200
Subject: [PATCH] Retry dm device removal if busy
In-Reply-To: <4E709A98.8070404@redhat.com>
References: <4E6F6958.5020609@redhat.com>
	<6E8B2169-8A1D-4682-B02E-9CEA8D1B6835@redhat.com>
	<4E709A98.8070404@redhat.com>
Message-ID: <4E709D6F.7080407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/14/2011 02:14 PM, Zdenek Kabelac wrote:
> (Thus I believe Petr should add lvm.conf option - and for buildbot this hack
> should be disabled - so the internal bugs are clearly visible.)

Builbot is just another user, I do not think we should test it without flag.
What it will prove? That udisks is still using watch? it does, really :-)

I have to always manually remove udev rule (breaking other things),
it is not dedicated machine.

Milan


