/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    xilinxcorelib_ver_m_00000000001358910285_0067036824_init();
    xilinxcorelib_ver_m_00000000001687936702_3549473565_init();
    xilinxcorelib_ver_m_00000000000277421008_1362359589_init();
    xilinxcorelib_ver_m_00000000001603977570_4245928422_init();
    work_m_00000000000403262735_1810801074_init();
    xilinxcorelib_ver_m_00000000001358910285_2200814358_init();
    xilinxcorelib_ver_m_00000000001687936702_0574952569_init();
    xilinxcorelib_ver_m_00000000000277421008_2906653765_init();
    xilinxcorelib_ver_m_00000000001603977570_1306881833_init();
    work_m_00000000000403262735_3188187887_init();
    work_m_00000000000403262735_0953003321_init();
    work_m_00000000003043188521_0437647295_init();
    work_m_00000000002729370533_0759027002_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000002729370533_0759027002");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
