From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 14:20:53 +0000
Subject: [PATCH 8/8] Add fs_unlock calls
In-Reply-To: <b2ab409f7ae9e45b2d974e565a67a6d2798b656c.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<b2ab409f7ae9e45b2d974e565a67a6d2798b656c.1294398815.git.zkabelac@redhat.com>
Message-ID: <20110107142053.GJ5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 12:17:36PM +0100, Zdenek Kabelac wrote:
> Add lvm_do_fs_unlock()
 
Ack.

> + at top_srcdir@/lib/activate/fs.h

Please would you export it via activate.h instead?
(I'd prefer not to expose the other functions in fs.h.)

Alasdair


