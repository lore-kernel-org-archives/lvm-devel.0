From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 22 Feb 2010 18:51:00 +0000
Subject: lvm and locales memory issue
In-Reply-To: <20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <20100222185100.GB32020@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 22, 2010 at 07:23:01PM +0100, Jakub Jelinek wrote:
> That's a bad idea.
 
So we're still no closer to a solution.

So far the only realistic workaround I can think of for Fedora is:

  At lvm startup, check the size of the locale-archive file and the amount of
  memory on the system.  If it looks critical, issue a warning and disable
  locale-setting in LVM.

(Which other distros are affected as well as Fedora/RHEL/CentOS?)

This workaround still does not address the fundamental problem:
glibc is holding open a large mmaped file on behalf of the process and
seemingly offering no way for the process to instruct it to close it without
exiting.

Alasdair


