Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE6D71DC731
	for <lvm-devel@lists.linux.dev>; Fri, 13 Sep 2024 13:56:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726235811; cv=none; b=eKJH4N0sAz1pN56wuvcbrPZjRcP+FfGxE3xRhCjkmt2kD+04xUXsEtaleOdAatQsuAtfTQfYvL3DXsTHbPXGUQnDmkupGMhxqFLWJhPGG/dQpYG5nWAraqkLipIpLXwbh6HjnK6NG5Tk1TWHgd6K6IkCDU2Z2OxexhyuE4NXJp8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726235811; c=relaxed/simple;
	bh=uj5cEJmlBXYTCZS0lpztmcB+Z64kRyrQ1yinTWqvIQE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=I7VUzKMJORBNbKNaXsOVxEW2sHhrkCSkeO0HN+5FL1ALGVKGnjhlojafErUWjPOBU4Zxm0y/TzKSaXbzJTP9Be23+ZDBDe76u3uKQMCXYmmyboMeX1sDtn3HmM6OS4pQAX+oTvgPhFqLRacrCPXnNKBMHIo1HA0FucYiYfQvu4U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Iz7DN99q; arc=none smtp.client-ip=209.85.128.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Iz7DN99q"
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-42cb806623eso20106885e9.2
        for <lvm-devel@lists.linux.dev>; Fri, 13 Sep 2024 06:56:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1726235808; x=1726840608; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=0s5l+B3ZYH9Rs3rcrGhUWeQMdV9Fd5NSIFtCosAmOxY=;
        b=Iz7DN99qX/5v6PL1q/O4/L2Hg6KTnHgtwvC7gojnrRHE3AabPcIBeM9vsC1bg1nfVl
         kkNBGWmeb7thDTjunj2VAL9DJnYfmY8QBmyyk33FqOikerBQSpE/gMiO+ry6UBR/6VAu
         fFrNtqYJpGSY+aCAOk0MnqUpy92Nj0Q9P90KweJYkyk+cmOwJHIlK71jN+OCKWd1gHlk
         mYRxXx7I7rHtwy5h4srWbYxj08tBVTeTR5LfPLDpQGVTk7ex1A9lkp73xygiX0elvKff
         jViXfaBqDZlBFFYngSrij9+Ee5IXKUJu81dbUnbTrwGlvejh7TH7h1fu5V1tGb/bfn+k
         IH9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726235808; x=1726840608;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=0s5l+B3ZYH9Rs3rcrGhUWeQMdV9Fd5NSIFtCosAmOxY=;
        b=XtneZW+OVaNH51cDf3JzUU3uyu4OsK3jf5AO2gK6L7GK3DcQ7nxtxeSDBogcXMirMu
         RwK/YeCoH3ggfJv3WQbw211+fFsX4ZSmQLIet1sX8FEefGfJDIoR5Z1CkJCPYKAcQyRX
         qqWiKlNQdnXf0cUNGmozkRrT/qM6T8DQjOZkr7N6k7IMwTwKMUnFCLdGq4mVVlW9iLVH
         d1oIHmyCQd/iOItq/OIcW32Kuj4cLULydQfYfXNalaem+R3L4i5H27g/mrPfUMk8nC18
         50pl4tNGR50fkCut7zogXJK7U/Js88OSKxmtFCy0P+1lBf4CpLehMC5XJ5HZQpRzAXGH
         G2MA==
X-Forwarded-Encrypted: i=1; AJvYcCUg02CqSXIRteqHhvNY1YGP2jQhx4j55GyzNah5cBdtr1DxNf4ppzHIIwsk98+jEJcZxbasefqAnRk=@lists.linux.dev
X-Gm-Message-State: AOJu0YwnKVKD/nh62/9sRPgnFz0dyPJqNYL3hQXpCLliiNfrQG90bpLr
	kj/LX842jv5Gcce7ux0bon+WhwPZkcyT01pow2xPMOGWtyO0ZCni
X-Google-Smtp-Source: AGHT+IExkQX1jMAt2Q63ePKUD5isP0VzNMAfU1WoSLVjcmKfb3lN2B3rjQqts3BDjByqI9Htwu61fg==
X-Received: by 2002:a05:600c:1d12:b0:42c:b22e:fc23 with SMTP id 5b1f17b1804b1-42cdb53b958mr54738725e9.15.1726235807767;
        Fri, 13 Sep 2024 06:56:47 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-42cc1374f61sm90094585e9.1.2024.09.13.06.56.46
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 13 Sep 2024 06:56:47 -0700 (PDT)
Message-ID: <51fdc9a7-8639-4c1a-b8a5-c3be0a5a61f5@gmail.com>
Date: Fri, 13 Sep 2024 15:56:46 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>,
 Ming Hung Tsai <mtsai@redhat.com>
Cc: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>,
 lvm-devel@lists.linux.dev
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com>
 <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
 <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
 <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
 <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Ming,
> I am still collecting results, so I will present findings that are
> confirmed so far.
> There is some good news too.
> 
> On Fri, Sep 13, 2024 at 1:11 AM Ming Hung Tsai <mtsai@redhat.com> wrote:
>>
>> Hi,
>>
>> On Wed, Sep 11, 2024 at 12:05 AM Lakshmi Narasimhan Sundararajan
>> <lsundararajan@purestorage.com> wrote:

> My application that is consuming the thin device pumps IO traffic
> directly on the raw block device.
> My application also keeps a journal record outside the thin pool and
> after power recycled, reading the data back
> did not guarantee sync consistency.
> 
> I wrote a sample program that is trying to recreate this outside my application.
> here it is: sulakshm/iotest: iotest (github.com)
> I am still refining it, as I have not seen the problem with this tool yet.
> But the logic is similar to how my application consumes thin dev; and
> my app can reproduce this very easily.
> 
> As I said before, I am still collecting additional information from
> many internal tests.
> So far, I can see this problem even in 6.5 kernel.
> 
> The latest distro/linux kernel where this problem is seen.
>> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 12 18:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> There is a workaround to this problem that is looking promising, tests
> ongoing still.
> 
> The sync point from my application is a sync(fd) of the thin dev.
> This has proven insufficient.
> In addition, I had to perform "dmsetup suspend pool -> dmsetup resume pool".
> This guarantees sync point consistency.
> 

Hi

Not exactly sure what your app is all exactly doing - however there is 
cut&paste from 'fsync()'  manpage:

---
Calling fsync() does not necessarily ensure that the entry in the directory 
containing the file has also  reached  disk.   For  that  an  explicit
fsync() on a file descriptor for the directory is also needed.
---

For this purpose our 'test suite' app basically  'opens' whole device and 
fsync and close it - to ensure synchronization point flush.

Thus 'suspend & resume' of the whole thin device could be possibly unnecessary 
- just do a fsync() on blockdevice fd.


You can also play fun games with 'fsfreeze' operation.

Regards

Zdenek


