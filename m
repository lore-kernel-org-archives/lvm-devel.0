From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 9 Oct 2009 17:03:11 +0200
Subject: [PATCH 02/11] debian: drop realtime
In-Reply-To: <20091008232825.GQ3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<ed17d1525f4431ee900974ee84df19a351b005b5.1255002311.git.fdinitto@redhat.com>
	<20091008232825.GQ3054@agk-dp.fab.redhat.com>
Message-ID: <20091009150311.GE6904@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 12:28:25AM +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:16:20PM +0200, Fabio M. Di Nitto wrote:
> > the realtime support is completely unused and just includes another library
> > dependency
> Just fix the build so REALTIME=no really does exclude it completely.

The code is not used. Why is it there?

Bastian

-- 
Warp 7 -- It's a law we can live with.


