From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Nov 2008 16:53:53 +0100
Subject: [PATCH] (7/11) API improvements
In-Reply-To: <1227499005.6608.16.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Sun, 23 Nov 2008 22:56:45 -0500")
References: <873aie3q69.fsf@eriador.mornfall.net>
	<1227499005.6608.16.camel@localhost.localdomain>
Message-ID: <87myfp6rxq.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> I believe this should be:
> 	if (!consistent && !failure) {
Indeed, and that's an actual bug. Noting it down. (Where I write "note down" I
mean that I fix it on my branch, so it'll be fixed in the final commit.)

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


