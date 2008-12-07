From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 7 Dec 2008 12:50:21 +0000
Subject: [PATCH] Add liblvm interactive test infrastructure to build.
In-Reply-To: <20081207121730.GJ26097@agk.fab.redhat.com>
References: <1228624391-904-1-git-send-email-dwysocha@redhat.com>
	<20081207121730.GJ26097@agk.fab.redhat.com>
Message-ID: <20081207125021.GL26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Dec 07, 2008 at 12:17:31PM +0000, Alasdair G Kergon wrote:
> For the public library, I think 0 = success fits better - that's what we
> have in our one other public library so far, liblvm2cmd
 
Actually that's false - there's only one function returning a value and
the interface fails to explain the meanings of its return values:-(

But I think the library function here should be void anyway so the specific
question doesn't arise yet:-)

Alasdair
-- 
agk at redhat.com


