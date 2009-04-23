From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 23 Apr 2009 22:34:26 +0100
Subject: RFC: Command line support to create sparse devices
In-Reply-To: <20090423211840.GA7421@agk-dp.fab.redhat.com>
References: <20090423211840.GA7421@agk-dp.fab.redhat.com>
Message-ID: <20090423213426.GA15019@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 23, 2009 at 10:18:41PM +0100, Alasdair G Kergon wrote:
> Here's a quick patch I've thrown together to make it easier to create sparse
> devices.
 
Unfinished bits I can think of:
  - disallow multiple snapshots of the same origin if origin is invisible
  - if origin is invisible, remove it when its snapshot is removed
  - deal with activation/deactivation by translating the command from the
    snapshot to the origin iff the origin is hidden

And it needs testing.

Alasdair
-- 
agk at redhat.com


