From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 13:40:03 +0200
Subject: [PATCH 29/30] Add some __attribute__ instrumentation
In-Reply-To: <87vd4q4kmp.wl%ejt@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>	<f5e7e192d1da549614124cc96a5669a80feb1680.1287994530.git.zkabelac@redhat.com>
	<87vd4q4kmp.wl%ejt@redhat.com>
Message-ID: <4CC56C93.4090204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.10.2010 12:44, ejt at redhat.com napsal(a):
> At Mon, 25 Oct 2010 10:24:36 +0200,
> Zdenek Kabelac wrote:
>>
>> Add some malloc intrumentation and warning attributes.
>>
>> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> 
> Ack.  But I question how far you intend to go with this.  Surely it's more unusual to return a value that can be ignored?
> 


I think wherever it is an error to ignore returned value on public API
function, we should put some warning.  In this case it must lead to memory
leak - so it's good idea to give the user this knowledge in compile time.

(btw I'm doing nothing more then what original system headers do for you :))

What seems to have some 'hidden' fruits are those 'nonnull' __attributes__.
We have quite a few functions which take a pointer and expect it to be
non-null - so we could mark these functions and get static analysis to be done
on them.

Zdenek


