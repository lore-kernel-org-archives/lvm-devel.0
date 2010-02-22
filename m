From: Jakub Jelinek <jakub@redhat.com>
Date: Mon, 22 Feb 2010 20:05:56 +0100
Subject: lvm and locales memory issue
In-Reply-To: <20100222185100.GB32020@agk-dp.fab.redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<20100222185100.GB32020@agk-dp.fab.redhat.com>
Message-ID: <20100222190555.GS2817@tyan-ft48-01.lab.bos.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 22, 2010 at 06:51:00PM +0000, Alasdair G Kergon wrote:
> This workaround still does not address the fundamental problem:
> glibc is holding open a large mmaped file on behalf of the process and
> seemingly offering no way for the process to instruct it to close it without
> exiting.

Guess we disagree what is the fundamental problem.  IMHO it is a big app
calling mlockall after it has called lots of functions from lots of
libraries.  mlockall really is meant to be used only in very small, tightly
controlled apps,  requiring every library function to be mlockall aware and
have some API for flush before mlockall is unrealistical.

	Jakub


