From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Mar 2009 12:15:23 -0400
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
Message-ID: <1237565723.2493.13.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-03-20 at 21:17 +0530, Sandeep K Sinha wrote:
> Hi all,
> Disk
> After hunting for relevant documents and failing to find one.
> I would like to know if its not true that the size of the snapshot
> should be equal to the original volume?
> If so, then why do we accept size for a snapshot?
> 
> Or Am I missing something somewhere else?
> 

The size for the snapshot is the exception store - basically the blocks
that get modified need some place to be stored.  This is why you need a
separate size for snapshot LV which may be very different (usually much
smaller) than the original LV.





