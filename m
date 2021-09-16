From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Sep 2021 21:59:11 +0200
Subject: thin vol write performance variance
In-Reply-To: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
References: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
Message-ID: <0e77c758-d804-61b6-73f1-3a268b03b6b2@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15. 09. 21 v 9:02 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> A very good day to you.
> 
> I have a lvm2 thin pool and thin volumes in my environment.
> I see a huge variance in write performance over those thin volumes.
> As one can observe from the logs below, the same quantum of write
> (~1.5G) to the thin volume (/dev/pwx0/608561273872404373) completes
> between 2s to 40s.
> The metadata is  defined as 128 sectors (64KB) on the thin pool.
> I understand that there is a late mapping of segments to thin volumes
> as IO requests come in.
> Is there a way to test/quantity that the overhead is because of this
> lazy mapping?
> Are there any other config/areas that I can tune to control this behavior?
> Are there any tunables/ioctl to control mapping regions ahead of time
> (ala readahead)?
> Any other options available to confirm this behavior is because of the
> lazy mapping and ways to improve it?
> 
> My intention is to improve this behavior and control the variance to a
> more tight bound.
> Looking forward to your inputs in helping me understand this better.
> 

Hi

I think we need to 'decipher' first some origins of your problems.

So what is your backend 'storage' in use?
Do you use fast device like ssd/nvme to store thin-pool metadata?

Do you measure your time *after* sync all of 'unwritten/buffered' data on disk ?

What is actually your hw in use  - RAM, CPU ?

Which kernel and lvm2 version is being used ?

Do you use/need zeroing of provisioned blocks (which may impact performance 
and can be disabled with lvcreate -Zn) ?

Do you measure writes while provisioning thin chunks or on already provisioned 
device?


Regards

Zdenek


