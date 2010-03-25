From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 25 Mar 2010 18:13:44 +0000
Subject: [PATCH 0/6] Makefile updates
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <20100325181344.GP5259@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 23, 2010 at 05:27:33PM +0100, Zdenek Kabelac wrote:
> This patch set fixes few minor Makefile errors mostly
> around clean & distclean targets. Major topic is the update 
> of cflow rules.
 
Go for it - check them in.

It's a bit of a hack, but 'make distclean' attempts to clean up everything
regardless of what configuration options were used last time the
configure script was run: it has to try to clean up stuff that was
created by previous configure options.

Alasdair


