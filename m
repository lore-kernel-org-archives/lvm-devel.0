From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 6 Oct 2009 12:47:02 +0100
Subject: [RFC][PATCH 1/5] support command string with space
In-Reply-To: <878wfwdvuj.fsf@twilight.int.mornfall.net.>
References: <4AC2A619.50404@redhat.com>
	<878wfwdvuj.fsf@twilight.int.mornfall.net.>
Message-ID: <20091006114702.GB15687@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 30, 2009 at 10:24:36PM +0200, Peter Rockai wrote:
> Anyway, a more correct solution would entail a lvm2_runv (or similarly named)
> function, that would take char **argv -- no escaping issues to care
> about. Since this just adds to the library, it should be backwards compatible
> just fine.

Yes - try a lvm2_runv() first, that simply bypasses the call to lvm_split().

Alasdair


