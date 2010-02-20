From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 19 Feb 2010 19:23:40 -0500
Subject: [RFC] WARNING: dev_open(xxx) called while suspended
In-Reply-To: <20100219164459.GS27427@agk-dp.fab.redhat.com>
References: <4B7EBA39.3070900@redhat.com>
	<20100219164459.GS27427@agk-dp.fab.redhat.com>
Message-ID: <4B7F2B8C.2080505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/19/10 11:44, Alasdair G Kergon wrote:
> On Fri, Feb 19, 2010 at 11:20:09AM -0500, Takahiro Yasui wrote:
>> warning message.
>>   WARNING: dev_open(xxx) called while suspended
>> Can I suppress it by lvm configuration or something?
>  
> No - if the message appears, it's means there's a bug that must be fixed:-)

The rough sequence of lvconvert is

  1. construct new VG/LV data structure
  2. vg_write()
  3. suspend_lv()
      memlock_count++
  4. vg_commit()
      remove_commit_cached_metadata()  => Invalidate lvmcache

  5. resume_lv()
       _lv_resume()
         lv_from_lvid()
           fmt_from_vgname()
             label_read() => WARNING is displayed
      memlock_count--

By adding remove_commit_cached_metadata(), lvmcache is invalidated and
devices were scanned in resume_lv() with memlock_count != 0.

Can we move remove_commit_cached_metadata() just before memlock_count--?

Thanks,
Taka


