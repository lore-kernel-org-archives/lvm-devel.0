From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 30 Nov 2010 13:07:21 +0000
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <4CF4EF33.8020105@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
	<4CEEEB09.5050508@redhat.com>
	<20101129224750.GT29380@agk-dp.fab.redhat.com>
	<4CF4EF33.8020105@redhat.com>
Message-ID: <20101130130720.GE19659@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 30, 2010 at 01:33:55PM +0100, Zdenek Kabelac wrote:
> It's not a problem to keep these little quirks only in my local tree (except
> we wont get cleaner Coverity reports as that one is made with CVS tree).
 
Coverity's web interface handles it nicely - you just mark it as a false
report and it ignores it next time.  Coverity scans broke down in February.

Amazingly, just today, a new scan has appeared with an updated web interface.
They normally ignore emails I send them, but let's see if they respond to a
request to give you access.

Alasdair


