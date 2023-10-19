Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com [209.85.167.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F9DF30F82
	for <lvm-devel@lists.linux.dev>; Thu, 19 Oct 2023 17:03:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=contractor.linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=contractor.linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=contractor.linuxfoundation.org header.i=@contractor.linuxfoundation.org header.b="VSL4xzzH"
Received: by mail-lf1-f49.google.com with SMTP id 2adb3069b0e04-507a0907896so8161901e87.2
        for <lvm-devel@lists.linux.dev>; Thu, 19 Oct 2023 10:03:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=contractor.linuxfoundation.org; s=google; t=1697734980; x=1698339780; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=/Onvocl7z9tTV39RCCW1Yld6Uw1oloVdWrBn7K39z6I=;
        b=VSL4xzzHqx8DhlyOYCyKvBWLIFHipleHT5i0UoHb48ovnKFmBDc+7Ss0eEAaaHauEE
         XIOwGL2FrA2NCXo8UXHPSM6kxlarutxckQG/3MOuOrh1u9cNngTpyx1c4yLSHOortefC
         rwZmpGHoSoi131xzvMLPNumsBmyZO11c81st1PbmFGM3gwX1I734Ep4EY0Fh79s+Jhho
         T55kpNYADjSNQYV0gpJMEhIB/ycW9L0z/ZqvdJNXON8mEmb0DhuHcY9oLJGX1Ah26YMq
         Db5odrawNxE5GhUx1yvz+QEUwoFRBSfx9P3s8tA0GJU+Ei7skY9gxK6vJTZkGHOuSKkG
         H+6w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697734980; x=1698339780;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=/Onvocl7z9tTV39RCCW1Yld6Uw1oloVdWrBn7K39z6I=;
        b=KYZf2C9wCUF300UOD6NSzBgCxqYTgh0xfzaOeinbdqHZSrJ7V9GlY+fqQGhitFus25
         xvUntfpCvHwOziHiJeidY4CUcFlYCbgbwym0w8n1R8n6t4pDJc8XxFhJvdvRkFjbJ1Jo
         +y4LBD7BygVgPuo3LnJqum5DNU1B0Ja52QWxZf0KBPuxAQXHK8ctmakDAFCUSk6624U5
         eTlIcBBb1qjOqrnxHJhpglKC/dWe22uRWbTQEZa808EOaZkSfehfPwRnmSYfiQu6rKAP
         Tq7QtbVLIrPOcEdTcNG/6M03XrHnaUbrRV5GZP0qNTKkErbPPK9JMIJlWvQSLC4atkSw
         b+YA==
X-Gm-Message-State: AOJu0YyLC++46JgLR2DWR8hRyny/Wf1gWrIm/xHZFJ/OYSFQ+LhiKfz8
	6EoG39ZXBs/eb1HPVs+Jp+7jvnzy3rCMGo+K+6kh/509iqwzBipbTjc=
X-Google-Smtp-Source: AGHT+IHLY01DQgHGEAnKm0cTJGPki9KdPzz70MvtolM1gaW8CWXDDkaW2TBiZRfyiUpuZW+6UecV4ZGNMAFKisfOHL8=
X-Received: by 2002:a05:6512:b8b:b0:507:b14f:e3bc with SMTP id
 b11-20020a0565120b8b00b00507b14fe3bcmr2315282lfv.33.1697734980440; Thu, 19
 Oct 2023 10:03:00 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Shyam Kumar <skachukattu@contractor.linuxfoundation.org>
Date: Thu, 19 Oct 2023 22:32:49 +0530
Message-ID: <CAH=dH98M=t+eDe3DpwjObO2YUuotgVXeP4+oTeQ_ra-fSpQ5tw@mail.gmail.com>
Subject: Test Mail
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hello:

 This is a test message to test successful delivery and start the
 archive for the list. Please ignore.

-- 
Regards
Shyam Kumar
The Linux Foundation Core Projects
