From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 15 Apr 2009 19:52:56 +0100
Subject: [PATCH 3/4] Udev integration: add cookie support for dmsetup
In-Reply-To: <49DC978E.4040101@redhat.com>
References: <49DC978E.4040101@redhat.com>
Message-ID: <20090415185256.GM7843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 08, 2009 at 02:24:46PM +0200, Peter Rajnoha wrote:
> A new command is added "notify" with the cookie value as the
> parameter. 

"Notify" is a very general term and we might want to use something similar in
an unrelated way in future: can we think up a more-specific command name?

Alasdair
-- 
agk at redhat.com


