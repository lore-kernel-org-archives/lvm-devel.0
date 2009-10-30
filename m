From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 30 Oct 2009 16:54:56 +0100
Subject: [PATCH] udev: move notify rule
In-Reply-To: <20091030145125.GA21583@wavehammer.waldi.eu.org>
References: <20091030145125.GA21583@wavehammer.waldi.eu.org>
Message-ID: <4AEB0C50.7090500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

On 10/30/2009 03:51 PM, Bastian Blank wrote:
> Move notify rule into the first rules file. The RUN commands is executed
> after everything is finished, so it makes no difference if it is set
> early or late.
> 

yes, this is true with respect to all the other udev processing. But the point of having
it as 95-dm.rules is that there could be some other RUN+="..." line in the other rules.
These are processed in sequence of their order of appearance then and we really would
like to send the notification after all this processing is done (considering those
"RUNs" as well)...

Peter


