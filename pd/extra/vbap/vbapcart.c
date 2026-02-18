/* vbapcart.c vers 1.0 (2026)
   Modified for 5 inlets layout (cartesian coordinates): 
   Inlet 0: Config/Bang
   Inlet 1: X
   Inlet 2: Y
   Inlet 3: Z
   Inlet 4: Spread
*/

#include <math.h>
#include "m_pd.h"

#define MAX_LS_SETS 385
#define MAX_LS_AMOUNT 200

/* --- STRUCTURE DEFINITIONS --- */
typedef struct vbap
{
    t_object x_ob;
    
    /* Inlets */
    t_float x_target_x;     
    t_float x_target_y;     
    t_float x_target_z;     
    t_float x_spread;       
    
    /* Intern values */
    float x_spread_base[3]; 
    
    /* Outlets */
    void *x_outlet0; /* List of Gains */
    void *x_outlet1; /* Passthrough X */
    void *x_outlet2; /* Passthrough Y */
    void *x_outlet3; /* Passthrough Z */
    void *x_outlet4; /* Passthrough Spread */

    /* Matrices and LS-Setup */
    float x_set_inv_matx[MAX_LS_SETS][9];
    float x_set_matx[MAX_LS_SETS][9];
    long x_lsset[MAX_LS_SETS][3];
    long x_lsset_available;
    long x_lsset_amount;
    long x_ls_amount;
    long x_dimension;       /* 2 or 3 */
} t_vbap;

static t_class *vbap_class;

/* --- prototypes --- */
void normalize_cartesian(float cart[3]);
void cross_prod(float v1[3], float v2[3], float v3[3]);
void additive_vbap(float *final_gs, float cartdir[3], t_vbap *x);
void vbap_cartesian(float g[3], long ls[3], float target_cart[3], t_vbap *x);

/* Spread fuctions */
void new_spread_dir(t_vbap *x, float spreaddir[3], float vscartdir[3], float spread_base[3]);
void new_spread_base(t_vbap *x, float spreaddir[3], float vscartdir[3]);
void spread_it(t_vbap *x, float *final_gs);

/* Pd Interface functions */
void vbap_bang(t_vbap *x);
void vbap_matrix(t_vbap *x, t_symbol *s, int ac, t_atom *av);
static void *vbap_new(t_symbol *s, int ac, t_atom *av);
void vbapcart_setup(void);

/* --- SETUP --- */
void vbapcart_setup(void)
{
    vbap_class = class_new(gensym("vbapcart"), (t_newmethod)vbap_new, 0, 
                          (short)sizeof(t_vbap), 0, A_GIMME, 0);
    
    /* Inlet 0 -> Bang -> calculation */
    class_addbang(vbap_class, vbap_bang);
    
    /* Inlet 0 accepts loudspeaker definitions */
    class_addmethod(vbap_class, (t_method)vbap_matrix, gensym("loudspeaker-matrices"), A_GIMME, 0);
}

/* --- help functions --- */

void normalize_cartesian(float cart[3])
{
    float length = sqrtf(cart[0]*cart[0] + cart[1]*cart[1] + cart[2]*cart[2]);
    if (length > 0.00001f) {
        cart[0] /= length;
        cart[1] /= length;
        cart[2] /= length;
    } else {
        cart[0] = 1.0f; cart[1] = 0.0f; cart[2] = 0.0f; /* Safety fallback */
    }
}

void cross_prod(float v1[3], float v2[3], float v3[3]) 
{
    float length;
    v3[0] = (v1[1] * v2[2] ) - (v1[2] * v2[1]);
    v3[1] = (v1[2] * v2[0] ) - (v1[0] * v2[2]);
    v3[2] = (v1[0] * v2[1] ) - (v1[1] * v2[0]);

    length = sqrtf(v3[0]*v3[0] + v3[1]*v3[1] + v3[2]*v3[2]);
    if(length > 0.00001f) {
        v3[0] /= length; v3[1] /= length; v3[2] /= length;
    }
}

/* --- VBAP --- */

void vbap_cartesian(float g[3], long ls[3], float target_cart[3], t_vbap *x)
{
    int i, j, k, gains_modified;
    float small_g, big_sm_g, gtmp[3];
    long winner_set = 0;
    long dim = x->x_dimension;
    long neg_g_am, best_neg_g_am;
    float cartdir[3];
    float power;
    
    cartdir[0] = target_cart[0];
    cartdir[1] = target_cart[1];
    cartdir[2] = target_cart[2];
    normalize_cartesian(cartdir);
    
    big_sm_g = -100000.0f;
    best_neg_g_am = 3;
    
    for(i=0; i<x->x_lsset_amount; i++){
        small_g = 10000000.0f;
        neg_g_am = 3;
        for(j=0; j<dim; j++){
            gtmp[j] = 0.0f;
            for(k=0; k<dim; k++)
                gtmp[j] += cartdir[k] * x->x_set_inv_matx[i][k+j*dim];
            
            if(gtmp[j] < small_g) small_g = gtmp[j];
            if(gtmp[j] >= -0.01f) neg_g_am--;
        }
        if(small_g > big_sm_g && neg_g_am <= best_neg_g_am){
            big_sm_g = small_g;
            best_neg_g_am = neg_g_am; 
            winner_set = i;
            g[0] = gtmp[0]; g[1] = gtmp[1];
            ls[0] = x->x_lsset[i][0]; ls[1] = x->x_lsset[i][1];
            if(dim==3){
                g[2] = gtmp[2];
                ls[2] = x->x_lsset[i][2];
            } else {
                g[2] = 0.0f;
                ls[2] = 0;
            }
        }
    }
    
    if(dim==3){
        gains_modified = 0;
        for(i=0; i<dim; i++)
            if(g[i] < -0.01f){
                g[i] = 0.0001f;
                gains_modified = 1;
            }    
    }
    
    power = sqrtf(g[0]*g[0] + g[1]*g[1] + g[2]*g[2]);
    if(power > 0.00001f) {
        g[0] /= power; g[1] /= power; g[2] /= power;
    }
}

void additive_vbap(float *final_gs, float cartdir[3], t_vbap *x)
{
    /* Spread */
    float g[3];
    long ls[3];
    int i, j, k, gains_modified;
    float small_g, big_sm_g, gtmp[3];
    long winner_set = 0;
    long dim = x->x_dimension;
    long neg_g_am, best_neg_g_am;
    float power;

    ls[0]=0; ls[1]=0; ls[2]=0;
    big_sm_g = -100000.0f;
    best_neg_g_am = 3;

    for(i=0; i<x->x_lsset_amount; i++){
        small_g = 10000000.0f;
        neg_g_am = 3;
        for(j=0; j<dim; j++){
            gtmp[j] = 0.0f;
            for(k=0; k<dim; k++)
                gtmp[j] += cartdir[k] * x->x_set_inv_matx[i][k+j*dim];
            if(gtmp[j] < small_g) small_g = gtmp[j];
            if(gtmp[j] >= -0.01f) neg_g_am--;
        }
        if(small_g > big_sm_g && neg_g_am <= best_neg_g_am){
            big_sm_g = small_g;
            best_neg_g_am = neg_g_am; 
            winner_set = i;
            g[0] = gtmp[0]; g[1] = gtmp[1];
            ls[0] = x->x_lsset[i][0]; ls[1] = x->x_lsset[i][1];
            if(dim==3){
                g[2] = gtmp[2];
                ls[2] = x->x_lsset[i][2];
            } else {
                g[2] = 0.0f;
                ls[2] = 0;
            }
        }
    }

    gains_modified = 0;
    for(i=0; i<dim; i++)
        if(g[i] < -0.01f) gains_modified = 1;
  
    if(gains_modified != 1){
        power = sqrtf(g[0]*g[0] + g[1]*g[1] + g[2]*g[2]);
        if(power > 0.00001f){
            g[0] /= power; g[1] /= power; g[2] /= power;
            final_gs[ls[0]-1] += g[0];
            final_gs[ls[1]-1] += g[1];
            final_gs[ls[2]-1] += g[2];
        }
    }
}

/* --- SPREAD logic --- */

void new_spread_dir(t_vbap *x, float spreaddir[3], float vscartdir[3], float spread_base[3])
{
    float beta, gamma;
    float a, b;
    float pi = 3.1415927f;
    float power;
    
    float dot = vscartdir[0] * spread_base[0] + vscartdir[1] * spread_base[1] + vscartdir[2] * spread_base[2];
    if (dot > 1.0f) dot = 1.0f;
    if (dot < -1.0f) dot = -1.0f;
    
    gamma = acosf(dot) / pi * 180.0f;

    if(fabs(gamma) < 1.0f){
        float temp[3] = {0,0,1};
        if(fabs(vscartdir[2]) > 0.9f) { temp[0]=1; temp[2]=0; }
        cross_prod(vscartdir, temp, spread_base);
        dot = vscartdir[0] * spread_base[0] + vscartdir[1] * spread_base[1] + vscartdir[2] * spread_base[2];
        if (dot > 1.0f) dot = 1.0f; if (dot < -1.0f) dot = -1.0f;
        gamma = acosf(dot) / pi * 180.0f;
    }
    
    beta = 180.0f - gamma;
    if (fabs(sinf(beta * pi / 180.0f)) < 0.00001f) {
        spreaddir[0] = vscartdir[0]; spreaddir[1] = vscartdir[1]; spreaddir[2] = vscartdir[2];
        return;
    }

    b = sinf(x->x_spread * pi / 180.0f) / sinf(beta * pi / 180.0f);
    a = sinf((180.0f - x->x_spread - beta) * pi / 180.0f) / sinf(beta * pi / 180.0f);
    
    spreaddir[0] = a * vscartdir[0] + b * spread_base[0];
    spreaddir[1] = a * vscartdir[1] + b * spread_base[1];
    spreaddir[2] = a * vscartdir[2] + b * spread_base[2];
    
    power = sqrtf(spreaddir[0]*spreaddir[0] + spreaddir[1]*spreaddir[1] + spreaddir[2]*spreaddir[2]);
    if(power > 0.00001f) {
        spreaddir[0] /= power; spreaddir[1] /= power; spreaddir[2] /= power;
    }
}

void new_spread_base(t_vbap *x, float spreaddir[3], float vscartdir[3])
{
    float d;
    float pi = 3.1415927f;
    float power;
    
    d = cosf(x->x_spread / 180.0f * pi);
    x->x_spread_base[0] = spreaddir[0] - d * vscartdir[0];
    x->x_spread_base[1] = spreaddir[1] - d * vscartdir[1];
    x->x_spread_base[2] = spreaddir[2] - d * vscartdir[2];
    
    power = sqrtf(x->x_spread_base[0]*x->x_spread_base[0] + 
                  x->x_spread_base[1]*x->x_spread_base[1] + 
                  x->x_spread_base[2]*x->x_spread_base[2]);
                  
    if(power > 0.00001f) {
        x->x_spread_base[0] /= power; x->x_spread_base[1] /= power; x->x_spread_base[2] /= power;
    }
}

void spread_it(t_vbap *x, float *final_gs)
{
    float vscartdir[3];
    float spreaddir[16][3];
    float spreadbase[16][3];
    long i, spreaddirnum;
    float power;
    
    vscartdir[0] = x->x_target_x;
    vscartdir[1] = x->x_target_y;
    vscartdir[2] = x->x_target_z;
    normalize_cartesian(vscartdir);

    if(x->x_dimension == 3){
        spreaddirnum = 16;
        new_spread_dir(x, spreaddir[0], vscartdir, x->x_spread_base);
        new_spread_base(x, spreaddir[0], vscartdir);
        
        cross_prod(x->x_spread_base, vscartdir, spreadbase[1]);
        cross_prod(spreadbase[1], vscartdir, spreadbase[2]);
        cross_prod(spreadbase[2], vscartdir, spreadbase[3]);
    
        for(i=0; i<3; i++) spreadbase[4][i] =  (x->x_spread_base[i] + spreadbase[1][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[5][i] =  (spreadbase[1][i] + spreadbase[2][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[6][i] =  (spreadbase[2][i] + spreadbase[3][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[7][i] =  (spreadbase[3][i] + x->x_spread_base[i]) / 2.0f;
        
        for(i=0; i<3; i++) spreadbase[8][i] =  (vscartdir[i] + x->x_spread_base[i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[9][i] =  (vscartdir[i] + spreadbase[1][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[10][i] =  (vscartdir[i] + spreadbase[2][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[11][i] =  (vscartdir[i] + spreadbase[3][i]) / 2.0f;
        
        for(i=0; i<3; i++) spreadbase[12][i] =  (vscartdir[i] + spreadbase[8][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[13][i] =  (vscartdir[i] + spreadbase[9][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[14][i] =  (vscartdir[i] + spreadbase[10][i]) / 2.0f;
        for(i=0; i<3; i++) spreadbase[15][i] =  (vscartdir[i] + spreadbase[11][i]) / 2.0f;
        
        additive_vbap(final_gs, spreaddir[0], x); 
        for(i=1; i<spreaddirnum; i++){
            new_spread_dir(x, spreaddir[i], vscartdir, spreadbase[i]);
            additive_vbap(final_gs, spreaddir[i], x); 
        }
    } else if (x->x_dimension == 2) {
       additive_vbap(final_gs, vscartdir, x);
    }
        
    if(x->x_spread > 70)
        for(i=0; i<x->x_ls_amount; i++)
            final_gs[i] += (x->x_spread - 70) / 30.0f * (x->x_spread - 70) / 30.0f * 10.0f;
    
    power = 0.0f;
    for(i=0; i<x->x_ls_amount; i++) power += final_gs[i] * final_gs[i];
    power = sqrtf(power);
    
    if(power > 0.00001f) {
        for(i=0; i<x->x_ls_amount; i++) final_gs[i] /= power;
    }
}

/* --- main functions PD --- */

void vbap_bang(t_vbap *x)            
{
    t_atom at[MAX_LS_AMOUNT]; 
    float g[3];
    long ls[3];
    long i;
    float *final_gs;
    float target_cart[3];
    
    final_gs = (float *) getbytes(x->x_ls_amount * sizeof(float));
    
    if(x->x_lsset_available == 1){
        target_cart[0] = x->x_target_x;
        target_cart[1] = x->x_target_y;
        target_cart[2] = x->x_target_z;
        
        vbap_cartesian(g, ls, target_cart, x);
        
        for(i=0; i<x->x_ls_amount; i++) final_gs[i] = 0.0f;             
        for(i=0; i<x->x_dimension; i++) final_gs[ls[i]-1] = g[i];
            
        if(x->x_spread != 0) spread_it(x, final_gs);
        
        /* output */
        for(i=0; i<x->x_ls_amount; i++) {
            SETFLOAT(&at[0], (t_float)i);    
            SETFLOAT(&at[1], (t_float)final_gs[i]);
            outlet_list(x->x_outlet0, gensym("list"), 2, at);
        }
        outlet_float(x->x_outlet4, x->x_spread); 
        outlet_float(x->x_outlet3, x->x_target_z); 
        outlet_float(x->x_outlet2, x->x_target_y); 
        outlet_float(x->x_outlet1, x->x_target_x); 
    }
    else
        post("vbapcart: Configure loudspeakers first!", 0);
        
    freebytes(final_gs, x->x_ls_amount * sizeof(float));
}

void vbap_matrix(t_vbap *x, t_symbol *s, int ac, t_atom *av)
{
    long counter = -1;
    long datapointer = 0;
    long setpointer = 0;
    long i;
 
    if(ac > 0) {
        if(av[datapointer].a_type == A_FLOAT){
            x->x_dimension = (long) av[datapointer++].a_w.w_float;
            x->x_lsset_available = 1;
        } else {
            post("Error in loudspeaker data!", 0);
            x->x_lsset_available = 0; return;
        }
    }
    if(ac > 1) {
        if(av[datapointer].a_type == A_FLOAT)
            x->x_ls_amount = (long) av[datapointer++].a_w.w_float;
        else {
            post("vbapcart: Error in loudspeaker data!", 0);
            x->x_lsset_available = 0; return;
        }
    } else x->x_lsset_available = 0;
    
    if(x->x_dimension == 3)
        counter = (ac - 2) / ((x->x_dimension * x->x_dimension * 2) + x->x_dimension);
    if(x->x_dimension == 2)
        counter = (ac - 2) / ((x->x_dimension * x->x_dimension) + x->x_dimension);
    x->x_lsset_amount = counter;

    if(counter <= 0){
        post("vbapcart: Error in loudspeaker data!", 0);
        x->x_lsset_available = 0; return;
    }
    
    post("vbapcart: %d loudspeakers found", x->x_ls_amount);
    
    while(counter-- > 0){
        for(i=0; i < x->x_dimension; i++){
            if(av[datapointer].a_type == A_FLOAT)
                 x->x_lsset[setpointer][i] = (long)av[datapointer++].a_w.w_float;
            else { x->x_lsset_available = 0; return; }
        }    
        for(i=0; i < x->x_dimension*x->x_dimension; i++){
            if(av[datapointer].a_type == A_FLOAT)
                x->x_set_inv_matx[setpointer][i] = av[datapointer++].a_w.w_float;
            else { x->x_lsset_available = 0; return; }
        }
        if(x->x_dimension == 3){ 
            for(i=0; i < x->x_dimension*x->x_dimension; i++){
                if(av[datapointer].a_type == A_FLOAT)
                    x->x_set_matx[setpointer][i] = av[datapointer++].a_w.w_float;
                else { x->x_lsset_available = 0; return; }
            }
        }
        setpointer++;
    }
    post("vbapcart: Loudspeaker setup configured!", 0);
}

static void *vbap_new(t_symbol *s, int ac, t_atom *av)    
{
    t_vbap *x = (t_vbap *)pd_new(vbap_class);

    /* Inlet 0 created automatically. */
    /* 4 more inlets for X, Y, Z, Spread */
    
    floatinlet_new(&x->x_ob, &x->x_target_x); /* Inlet 1: X */
    floatinlet_new(&x->x_ob, &x->x_target_y); /* Inlet 2: Y */
    floatinlet_new(&x->x_ob, &x->x_target_z); /* Inlet 3: Z */
    floatinlet_new(&x->x_ob, &x->x_spread);   /* Inlet 4: Spread */

    /* Outlets */
    x->x_outlet0 = outlet_new(&x->x_ob, gensym("list"));  
    x->x_outlet1 = outlet_new(&x->x_ob, gensym("float")); 
    x->x_outlet2 = outlet_new(&x->x_ob, gensym("float")); 
    x->x_outlet3 = outlet_new(&x->x_ob, gensym("float")); 
    x->x_outlet4 = outlet_new(&x->x_ob, gensym("float")); 

    /* Default */
    x->x_target_x = 1.0f; 
    x->x_target_y = 0.0f;
    x->x_target_z = 0.0f;
    x->x_spread = 0.0f;
    
    x->x_spread_base[0] = 0.0f;
    x->x_spread_base[1] = 1.0f;
    x->x_spread_base[2] = 0.0f;
    
    x->x_lsset_available = 0;
    
    /* process arguments (optional) */
    if (ac > 0 && av[0].a_type == A_FLOAT) x->x_target_x = av[0].a_w.w_float;        
    if (ac > 1 && av[1].a_type == A_FLOAT) x->x_target_y = av[1].a_w.w_float;    
    if (ac > 2 && av[2].a_type == A_FLOAT) x->x_target_z = av[2].a_w.w_float;
    
    return(x);                    
}
