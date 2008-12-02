From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 01 Dec 2008 22:12:11 -0500
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <20081202024827.GH26097@agk.fab.redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
	<1228057068.3315.33.camel@localhost.localdomain>
	<20081201135915.GB26097@agk.fab.redhat.com>
	<1228184768.3256.25.camel@localhost.localdomain>
	<20081202024313.GG26097@agk.fab.redhat.com>
	<20081202024827.GH26097@agk.fab.redhat.com>
Message-ID: <1228187531.3256.28.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2008-12-02 at 02:48 +0000, Alasdair G Kergon wrote:
> On Tue, Dec 02, 2008 at 02:43:13AM +0000, Alasdair G Kergon wrote:
> > Split the validation into optional validation and compulsory validation.
> > Offer separate library call(s) for the optional validation, but build
> > the compulsory validation into the main call(s).
>  
> So looking at pvcreate, most of pvcreate_check() is optional and depending
> on error handling could be done as one piece or broken into multiple functions.
> The few bits of compulsory validation move out of there into the actual 
> pvcreate call (which is performed via a vgextend() interface now).
> 

Ok, I did not understand that we are going to allow an APP the option to
bypass what was in pvcreate_check() (except the exclusive device open
check).


