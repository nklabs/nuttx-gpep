/****************************************************************************
 * arch/arm/src/sam34/sam_rtt.h
 *
 *   Copyright (C) 2014 Gregory Nutt. All rights reserved.
 *   Authors: Gregory Nutt <gnutt@nuttx.org>
 *            Bob Doiron
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name NuttX nor the names of its contributors may be
 *    used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

#ifndef __ARCH_ARM_SRC_SAM34_RTT_H
#define __ARCH_ARM_SRC_SAM34_RTT_H

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>

#include "chip.h"
#include "chip/sam_rtt.h"

#ifdef CONFIG_TIMER

/****************************************************************************
 * Pre-processor Definitions
 ****************************************************************************/

#ifndef __ASSEMBLY__

#undef EXTERN
#if defined(__cplusplus)
#define EXTERN extern "C"
extern "C"
{
#else
#define EXTERN extern
#endif

/****************************************************************************
 * Public Functions
 ****************************************************************************/

#if defined(CONFIG_SAM34_RTT)

/****************************************************************************
 * Name: sam_rttinitialize
 *
 * Description:
 *   Initialize the timer.  The timer is initialized and registers as
 *   'devpath.  The initial state of the timer is disabled.
 *
 * Input Parameters:
 *   devpath - The full path to the timer.  This should be of the form
 *     /dev/rtt0
 *
 * Returned Values:
 *   None
 *
 ****************************************************************************/

void sam_rttinitialize(FAR const char *devpath);

#endif // CONFIG_SAM34_RTT


#undef EXTERN
#if defined(__cplusplus)
}
#endif

#endif /* __ASSEMBLY__ */
#endif /* CONFIG_TIMER */
#endif /* __ARCH_ARM_SRC_SAM34_RTT_H */
