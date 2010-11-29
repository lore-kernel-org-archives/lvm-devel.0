From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:50:42 +0000
Subject: [PATCH 25/29] Check for unlink result
In-Reply-To: <6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129215042.GN29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:29AM +0100, Zdenek Kabelac wrote:
> Even if we intentionally wish to silently ignore any error from
> unlink in this place - it might be still good idea to put at least
> a debug message to get the reason for failure.

Don't see why not.
Ack.
 
> Test makes static analyzer happier about checked unlink result.

It's a project standard that all return values should be checked
(or explicitly discarded with a cast to void).
 
Alasdair


