From: Milan Broz <mbroz@redhat.com>
Date: Wed, 10 Jun 2009 11:35:47 +0200
Subject: [PATCH] Complain when lvconvert --repair is used on non-mirror LV.
In-Reply-To: <87ski8myjt.fsf@mornfall.net>
References: <87ski8myjt.fsf@mornfall.net>
Message-ID: <4A2F7E73.4050307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> just a trivial patch to make things clear when people mistakenly run lvconvert
> --repair on a non-mirrored LV (otherwise, this would succeed silently doing
> nothing).

ack.

Milan


