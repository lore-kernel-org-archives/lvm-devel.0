From: Bastian Blank <bastian@waldi.eu.org>
Date: Wed, 4 Nov 2009 12:26:55 +0100
Subject: [PATCH] udev: move notify rule
In-Reply-To: <4AEB0C50.7090500@redhat.com>
References: <20091030145125.GA21583@wavehammer.waldi.eu.org>
	<4AEB0C50.7090500@redhat.com>
Message-ID: <20091104112655.GB17814@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 30, 2009 at 04:54:56PM +0100, Peter Rajnoha wrote:
> On 10/30/2009 03:51 PM, Bastian Blank wrote:
> > Move notify rule into the first rules file. The RUN commands is executed
> > after everything is finished, so it makes no difference if it is set
> > early or late.
> yes, this is true with respect to all the other udev processing. But the point of having
> it as 95-dm.rules is that there could be some other RUN+="..." line in the other rules.

And there are no constraints about the order of this executions. If you
know more then the udev docu, fix it there.

Bastian

-- 
Where there's no emotion, there's no motive for violence.
		-- Spock, "Dagger of the Mind", stardate 2715.1


