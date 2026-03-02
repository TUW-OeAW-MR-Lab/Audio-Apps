/* vbapcart.c vers 0.99 for max4.0

written by Ville Pulkki 1999-2001
Helsinki University of Technology
and
Unversity of California at Berkeley

See copyright in file with name COPYRIGHT

Modified: Cartesian coordinate input/output (x, y, z) instead of
azimuth/elevation angles. Inputs:  1) loudspeaker-matrices (from
define_loudspeakerscart) 2) X position (cartesian) 3) Y position (cartesian) 4)
Z position (cartesian) 5) spread (0-100) Outputs: 1) DAC levels of loudspeakers
         2) X position actual (cartesian)
         3) Y position actual (cartesian)
         4) Z position actual (cartesian)
         5) spread actual
*/

#ifdef NT
// #define sqrtf sqrt
#endif

#include "m_pd.h" /* you must include this - it contains the external object's link to pure data */
#include <math.h>

#define RES_ID 9171 /* resource ID for assistance (we'll add that later) */
#define MAX_LS_SETS                                                            \
  385 /* maximum number of loudspeaker sets (triplets or pairs) allowed */
#define MAX_LS_AMOUNT 200 /* maximum amount of loudspeakers, can be increased  \
                           */

typedef struct vbapcart /* This defines the object as an entity made up of other
                           things */
{
  t_object x_ob;
  t_float x_x;     /* panning direction X (cartesian) */
  t_float x_y;     /* panning direction Y (cartesian) */
  t_float x_z;     /* panning direction Z (cartesian) */
  void *x_outlet0; /* outlet creation - inlets are automatic */
  void *x_outlet1;
  void *x_outlet2;
  void *x_outlet3;
  void *x_outlet4;
  float x_set_inv_matx[MAX_LS_SETS]
                      [9]; /* inverse matrice for each loudspeaker set */
  float x_set_matx[MAX_LS_SETS][9]; /* matrice for each loudspeaker set */
  long x_lsset[MAX_LS_SETS]
              [3];        /* channel numbers of loudspeakers in each LS set */
  long x_lsset_available; /* have loudspeaker sets been defined with
                             define_loudspeakers */
  long x_lsset_amount;    /* amount of loudspeaker sets */
  long x_ls_amount;       /* amount of loudspeakers */
  long x_dimension;       /* 2 or 3 */
  t_float x_spread;       /* speading amount of virtual source (0-100) */
  float x_spread_base[3]; /* used to create uniform spreading */
} t_vbapcart;

/* Globals */

void new_spread_dir(t_vbapcart *x, float spreaddir[3], float vscartdir[3],
                    float spread_base[3]);
void new_spread_base(t_vbapcart *x, float spreaddir[3], float vscartdir[3]);
static t_class *vbapcart_class;
void cross_prod(float v1[3], float v2[3], float v3[3]);
void additive_vbapcart(float *final_gs, float cartdir[3], t_vbapcart *x);
void vbapcart_bang(t_vbapcart *x);
void vbapcart_int(t_vbapcart *x, t_float n);
void vbapcart_matrix(t_vbapcart *x, t_symbol *s, int ac, t_atom *av);
void vbapcart_in1(t_vbapcart *x, long n);
void vbapcart_in2(t_vbapcart *x, long n);
void vbapcart_in3(t_vbapcart *x, long n);
void vbapcart_in4(t_vbapcart *x, long n);
void spread_it(t_vbapcart *x, float *final_gs);
static void *vbapcart_new(t_symbol *s, int ac,
                          t_atom *av); /* using A_GIMME - typed message list */
void vbapcart(float g[3], long ls[3], t_vbapcart *x);
void cart_to_angle(float cvec[3], float avec[3]);
void normalize_cart(float vec[3]);

/* above are the prototypes for the methods/procedures/functions you will use */

void vbapcart_setup(void) {
  vbapcart_class = class_new(gensym("vbapcart"), (t_newmethod)vbapcart_new, 0,
                             (short)sizeof(t_vbapcart), 0, A_GIMME, 0);
  /* vbapcart_new = creation function, A_DEFLONG = its (optional) arguement is a
   * long (32-bit) int */

  /* pure data: */

  class_addbang(vbapcart_class, vbapcart_bang);
  class_addfloat(vbapcart_class, vbapcart_int);
  class_addmethod(vbapcart_class, (t_method)vbapcart_matrix,
                  gensym("loudspeaker-matrices"), A_GIMME, 0);
}

void normalize_cart(float vec[3])
/* normalises a cartesian vector to unit length */
{
  float len = sqrtf(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
  if (len > 0.0001f) {
    vec[0] /= len;
    vec[1] /= len;
    vec[2] /= len;
  }
}

void cart_to_angle(float cvec[3], float avec[3])
/* converts cartesian coordinates to angular */
{
  float tmp, tmp2, tmp3, tmp4;
  float atorad = (2 * 3.1415927 / 360);
  float pi = 3.1415927;
  float power;
  float dist, atan_y_per_x, atan_x_pl_y_per_z;
  float azi, ele;

  if (cvec[0] == 0.0)
    atan_y_per_x = pi / 2;
  else
    atan_y_per_x = atan(cvec[1] / cvec[0]);
  azi = atan_y_per_x / atorad;
  if (cvec[0] < 0.0)
    azi += 180;
  dist = sqrt(cvec[0] * cvec[0] + cvec[1] * cvec[1]);
  if (cvec[2] == 0.0)
    atan_x_pl_y_per_z = 0.0;
  else
    atan_x_pl_y_per_z = atan(cvec[2] / dist);
  if (dist == 0.0) {
    if (cvec[2] < 0.0)
      atan_x_pl_y_per_z = -pi / 2.0;
    else
      atan_x_pl_y_per_z = pi / 2.0;
  }
  ele = atan_x_pl_y_per_z / atorad;
  dist = sqrtf(cvec[0] * cvec[0] + cvec[1] * cvec[1] + cvec[2] * cvec[2]);
  avec[0] = azi;
  avec[1] = ele;
  avec[2] = dist;
}

void vbapcart(float g[3], long ls[3], t_vbapcart *x) {
  /* calculates gain factors using loudspeaker setup and given cartesian
   * direction */
  float power;
  int i, j, k, gains_modified;
  float small_g;
  float big_sm_g, gtmp[3];
  long winner_set = 0;
  float cartdir[3];
  float new_cartdir[3];
  long dim = x->x_dimension;
  long neg_g_am, best_neg_g_am;

  gtmp[0] = 0;
  gtmp[1] = 0;
  gtmp[2] = 0;

  /* use cartesian input directly, normalise to unit sphere */
  cartdir[0] = x->x_x;
  cartdir[1] = x->x_y;
  cartdir[2] = (dim == 3) ? x->x_z : 0.0f;
  normalize_cart(cartdir);

  /* go through all defined loudspeaker sets and find the set which
  // has all positive values. If such is not found, set with largest
  // minimum value is chosen. If at least one of gain factors of one LS set is
  negative
  // it means that the virtual source does not lie in that LS set. */

  big_sm_g = -100000.0; /* initial value for largest minimum gain value */
  best_neg_g_am = 3;    /* how many negative values in this set */

  for (i = 0; i < x->x_lsset_amount; i++) {
    small_g = 10000000.0;
    neg_g_am = 3;
    for (j = 0; j < dim; j++) {
      gtmp[j] = 0.0;
      for (k = 0; k < dim; k++)
        gtmp[j] += cartdir[k] * x->x_set_inv_matx[i][k + j * dim];
      if (gtmp[j] < small_g)
        small_g = gtmp[j];
      if (gtmp[j] >= -0.01)
        neg_g_am--;
    }
    if (small_g > big_sm_g && neg_g_am <= best_neg_g_am) {
      big_sm_g = small_g;
      best_neg_g_am = neg_g_am;
      winner_set = i;
      g[0] = gtmp[0];
      g[1] = gtmp[1];
      ls[0] = x->x_lsset[i][0];
      ls[1] = x->x_lsset[i][1];
      if (dim == 3) {
        g[2] = gtmp[2];
        ls[2] = x->x_lsset[i][2];
      } else {
        g[2] = 0.0;
        ls[2] = 0;
      }
    }
  }

  /* If chosen set produced a negative value, make it zero and
  // calculate direction that corresponds to these new gain values.
  // This happens when the virtual source is outside of all loudspeaker sets. */

  if (dim == 3) {
    gains_modified = 0;
    for (i = 0; i < dim; i++)
      if (g[i] < -0.01) {
        g[i] = 0.0001;
        gains_modified = 1;
      }
    if (gains_modified == 1) {
      new_cartdir[0] = x->x_set_matx[winner_set][0] * g[0] +
                       x->x_set_matx[winner_set][1] * g[1] +
                       x->x_set_matx[winner_set][2] * g[2];
      new_cartdir[1] = x->x_set_matx[winner_set][3] * g[0] +
                       x->x_set_matx[winner_set][4] * g[1] +
                       x->x_set_matx[winner_set][5] * g[2];
      new_cartdir[2] = x->x_set_matx[winner_set][6] * g[0] +
                       x->x_set_matx[winner_set][7] * g[1] +
                       x->x_set_matx[winner_set][8] * g[2];
      /* store back actual clamped direction as cartesian */
      x->x_x = new_cartdir[0];
      x->x_y = new_cartdir[1];
      x->x_z = new_cartdir[2];
    }
  }

  power = sqrt(g[0] * g[0] + g[1] * g[1] + g[2] * g[2]);
  g[0] /= power;
  g[1] /= power;
  g[2] /= power;
}

void cross_prod(float v1[3], float v2[3], float v3[3])
/* vector cross product */
{
  float length;
  v3[0] = (v1[1] * v2[2]) - (v1[2] * v2[1]);
  v3[1] = (v1[2] * v2[0]) - (v1[0] * v2[2]);
  v3[2] = (v1[0] * v2[1]) - (v1[1] * v2[0]);

  length = sqrt(v3[0] * v3[0] + v3[1] * v3[1] + v3[2] * v3[2]);
  v3[0] /= length;
  v3[1] /= length;
  v3[2] /= length;
}

void additive_vbapcart(float *final_gs, float cartdir[3], t_vbapcart *x)
/* calculates gains to be added to previous gains, used in
// multiple direction panning (source spreading) */
{
  float power;
  int i, j, k, gains_modified;
  float small_g;
  float big_sm_g, gtmp[3];
  long winner_set;
  float new_cartdir[3];
  long dim = x->x_dimension;
  long neg_g_am, best_neg_g_am;
  float g[3];
  long ls[3];

  ls[0] = 0;
  ls[1] = 0;
  ls[2] = 0;

  big_sm_g = -100000.0;
  best_neg_g_am = 3;

  for (i = 0; i < x->x_lsset_amount; i++) {
    small_g = 10000000.0;
    neg_g_am = 3;
    for (j = 0; j < dim; j++) {
      gtmp[j] = 0.0;
      for (k = 0; k < dim; k++)
        gtmp[j] += cartdir[k] * x->x_set_inv_matx[i][k + j * dim];
      if (gtmp[j] < small_g)
        small_g = gtmp[j];
      if (gtmp[j] >= -0.01)
        neg_g_am--;
    }
    if (small_g > big_sm_g && neg_g_am <= best_neg_g_am) {
      big_sm_g = small_g;
      best_neg_g_am = neg_g_am;
      winner_set = i;
      g[0] = gtmp[0];
      g[1] = gtmp[1];
      ls[0] = x->x_lsset[i][0];
      ls[1] = x->x_lsset[i][1];
      if (dim == 3) {
        g[2] = gtmp[2];
        ls[2] = x->x_lsset[i][2];
      } else {
        g[2] = 0.0;
        ls[2] = 0;
      }
    }
  }

  gains_modified = 0;
  for (i = 0; i < dim; i++)
    if (g[i] < -0.01) {
      gains_modified = 1;
    }

  if (gains_modified != 1) {
    power = sqrt(g[0] * g[0] + g[1] * g[1] + g[2] * g[2]);
    g[0] /= power;
    g[1] /= power;
    g[2] /= power;

    final_gs[ls[0] - 1] += g[0];
    final_gs[ls[1] - 1] += g[1];
    final_gs[ls[2] - 1] += g[2];
  }
}

void new_spread_dir(t_vbapcart *x, float spreaddir[3], float vscartdir[3],
                    float spread_base[3])
/* subroutine for spreading */
{
  float beta, gamma;
  float a, b;
  float pi = 3.1415927;
  float power;
  float tmp_base[3];

  gamma = acos(vscartdir[0] * spread_base[0] + vscartdir[1] * spread_base[1] +
               vscartdir[2] * spread_base[2]) /
          pi * 180;
  if (fabs(gamma) < 1) {
    /* generate a perpendicular base vector by using cross product */
    float perp[3];
    /* pick an arbitrary vector not parallel to vscartdir */
    if (fabs(vscartdir[0]) < 0.9f) {
      perp[0] = 1.0f;
      perp[1] = 0.0f;
      perp[2] = 0.0f;
    } else {
      perp[0] = 0.0f;
      perp[1] = 1.0f;
      perp[2] = 0.0f;
    }
    /* cross product to get perpendicular */
    tmp_base[0] = vscartdir[1] * perp[2] - vscartdir[2] * perp[1];
    tmp_base[1] = vscartdir[2] * perp[0] - vscartdir[0] * perp[2];
    tmp_base[2] = vscartdir[0] * perp[1] - vscartdir[1] * perp[0];
    normalize_cart(tmp_base);
    spread_base[0] = tmp_base[0];
    spread_base[1] = tmp_base[1];
    spread_base[2] = tmp_base[2];
    gamma = acos(vscartdir[0] * spread_base[0] + vscartdir[1] * spread_base[1] +
                 vscartdir[2] * spread_base[2]) /
            pi * 180;
  }
  beta = 180 - gamma;
  b = sin(x->x_spread * pi / 180) / sin(beta * pi / 180);
  a = sin((180 - x->x_spread - beta) * pi / 180) / sin(beta * pi / 180);
  spreaddir[0] = a * vscartdir[0] + b * spread_base[0];
  spreaddir[1] = a * vscartdir[1] + b * spread_base[1];
  spreaddir[2] = a * vscartdir[2] + b * spread_base[2];

  power = sqrt(spreaddir[0] * spreaddir[0] + spreaddir[1] * spreaddir[1] +
               spreaddir[2] * spreaddir[2]);
  spreaddir[0] /= power;
  spreaddir[1] /= power;
  spreaddir[2] /= power;
}

void new_spread_base(t_vbapcart *x, float spreaddir[3], float vscartdir[3])
/* subroutine for spreading */
{
  float d;
  float pi = 3.1415927;
  float power;

  d = cos(x->x_spread / 180 * pi);
  x->x_spread_base[0] = spreaddir[0] - d * vscartdir[0];
  x->x_spread_base[1] = spreaddir[1] - d * vscartdir[1];
  x->x_spread_base[2] = spreaddir[2] - d * vscartdir[2];
  power = sqrt(x->x_spread_base[0] * x->x_spread_base[0] +
               x->x_spread_base[1] * x->x_spread_base[1] +
               x->x_spread_base[2] * x->x_spread_base[2]);
  x->x_spread_base[0] /= power;
  x->x_spread_base[1] /= power;
  x->x_spread_base[2] /= power;
}

void spread_it(t_vbapcart *x, float *final_gs)
/*
// apply the sound signal to multiple panning directions
// that causes some spreading.
// See theory in paper V. Pulkki "Uniform spreading of amplitude panned
// virtual sources" in WASPAA 99
*/
{
  float vscartdir[3];
  float spreaddir[16][3];
  float spreadbase[16][3];
  long i, spreaddirnum;
  float power;

  /* build the normalised vscartdir from current X/Y/Z */
  vscartdir[0] = x->x_x;
  vscartdir[1] = x->x_y;
  vscartdir[2] = (x->x_dimension == 3) ? x->x_z : 0.0f;
  normalize_cart(vscartdir);

  if (x->x_dimension == 3) {
    spreaddirnum = 16;
    new_spread_dir(x, spreaddir[0], vscartdir, x->x_spread_base);
    new_spread_base(x, spreaddir[0], vscartdir);
    cross_prod(x->x_spread_base, vscartdir,
               spreadbase[1]); /* four orthogonal dirs */
    cross_prod(spreadbase[1], vscartdir, spreadbase[2]);
    cross_prod(spreadbase[2], vscartdir, spreadbase[3]);

    /* four between them */
    for (i = 0; i < 3; i++)
      spreadbase[4][i] = (x->x_spread_base[i] + spreadbase[1][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[5][i] = (spreadbase[1][i] + spreadbase[2][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[6][i] = (spreadbase[2][i] + spreadbase[3][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[7][i] = (spreadbase[3][i] + x->x_spread_base[i]) / 2.0;

    /* four at half spreadangle */
    for (i = 0; i < 3; i++)
      spreadbase[8][i] = (vscartdir[i] + x->x_spread_base[i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[9][i] = (vscartdir[i] + spreadbase[1][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[10][i] = (vscartdir[i] + spreadbase[2][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[11][i] = (vscartdir[i] + spreadbase[3][i]) / 2.0;

    /* four at quarter spreadangle */
    for (i = 0; i < 3; i++)
      spreadbase[12][i] = (vscartdir[i] + spreadbase[8][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[13][i] = (vscartdir[i] + spreadbase[9][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[14][i] = (vscartdir[i] + spreadbase[10][i]) / 2.0;
    for (i = 0; i < 3; i++)
      spreadbase[15][i] = (vscartdir[i] + spreadbase[11][i]) / 2.0;

    additive_vbapcart(final_gs, spreaddir[0], x);
    for (i = 1; i < spreaddirnum; i++) {
      new_spread_dir(x, spreaddir[i], vscartdir, spreadbase[i]);
      additive_vbapcart(final_gs, spreaddir[i], x);
    }
  } else if (x->x_dimension == 2) {
    /* 2-D spreading: rotate in azimuth around the virtual source direction */
    float angle_to_rad = 3.1415927 / 180.0f;
    float avec[3];
    cart_to_angle(vscartdir, avec);
    float azi = avec[0];
    float spread = x->x_spread;

    spreaddirnum = 6;
    float spread_azis[6];
    spread_azis[0] = azi - spread;
    spread_azis[1] = azi - spread / 2;
    spread_azis[2] = azi - spread / 4;
    spread_azis[3] = azi + spread / 4;
    spread_azis[4] = azi + spread / 2;
    spread_azis[5] = azi + spread;

    for (i = 0; i < spreaddirnum; i++) {
      spreaddir[i][0] = cos(spread_azis[i] * angle_to_rad);
      spreaddir[i][1] = sin(spread_azis[i] * angle_to_rad);
      spreaddir[i][2] = 0.0f;
    }
    for (i = 0; i < spreaddirnum; i++)
      additive_vbapcart(final_gs, spreaddir[i], x);
  } else
    return;

  if (x->x_spread > 70)
    for (i = 0; i < x->x_ls_amount; i++) {
      final_gs[i] +=
          (x->x_spread - 70) / 30.0 * (x->x_spread - 70) / 30.0 * 10.0;
    }

  for (i = 0, power = 0.0; i < x->x_ls_amount; i++) {
    power += final_gs[i] * final_gs[i];
  }

  power = sqrt(power);
  for (i = 0; i < x->x_ls_amount; i++) {
    final_gs[i] /= power;
  }
}

void vbapcart_bang(t_vbapcart *x)
/* top level, vbapcart gains are calculated and outputted */
{
  t_atom at[MAX_LS_AMOUNT];
  float g[3];
  long ls[3];
  long i;
  float *final_gs;

  final_gs = (float *)getbytes(x->x_ls_amount * sizeof(float));
  if (x->x_lsset_available == 1) {
    vbapcart(g, ls, x);
    for (i = 0; i < x->x_ls_amount; i++)
      final_gs[i] = 0.0;
    for (i = 0; i < x->x_dimension; i++) {
      final_gs[ls[i] - 1] = g[i];
    }
    if (x->x_spread != 0) {
      spread_it(x, final_gs);
    }
    for (i = 0; i < x->x_ls_amount; i++) {
      SETFLOAT(&at[0], (t_float)i);
      SETFLOAT(&at[1], (t_float)final_gs[i]);
      outlet_list(x->x_outlet0, gensym("list") /* was: 0L */, 2, at);
    }
    outlet_float(x->x_outlet1, x->x_x);
    outlet_float(x->x_outlet2, x->x_y);
    outlet_float(x->x_outlet3, x->x_z);
    outlet_float(x->x_outlet4, x->x_spread);
  } else
    post("vbapcart: Configure loudspeakers first!", 0);
  /*	freebytes(final_gs, x->x_ls_amount * sizeof(float)); bug fix added 9/00
   */
}

/*--------------------------------------------------------------------------*/

void vbapcart_int(t_vbapcart *x,
                  t_float n) /* x = the instance of the object, n = the int
                                received in the right inlet */
{
  /* do something if an int comes in the left inlet??? */
}

void vbapcart_matrix(t_vbapcart *x, t_symbol *s, int ac, t_atom *av)
/* read in loudspeaker matrices */
{
  long counter = -1;
  long datapointer = 0;
  long setpointer = 0;
  long i;
  long deb = 0;

  if (ac > 0) {
    /* 		if(av[datapointer].a_type == A_LONG){
                            x->x_dimension = av[datapointer++].a_w.w_long;
                            x->x_lsset_available=1;
                    } else */
    if (av[datapointer].a_type == A_FLOAT) {
      x->x_dimension = (long)av[datapointer++].a_w.w_float;
      x->x_lsset_available = 1;
    } else {
      post("Error in loudspeaker data!", 0);
      x->x_lsset_available = 0;
      return;
    }
  }
  /* 	post("%d",deb++); */
  if (ac > 1)
    /* 		if(av[datapointer].a_type == A_LONG)
                            x->x_ls_amount = av[datapointer++].a_w.w_long;
                    else */
    if (av[datapointer].a_type == A_FLOAT)
      x->x_ls_amount = (long)av[datapointer++].a_w.w_float;
    else {
      post("vbapcart: Error in loudspeaker data!", 0);
      x->x_lsset_available = 0;
      return;
    }
  else
    x->x_lsset_available = 0;

  /* 	post("%d",deb++); */
  if (x->x_dimension == 3)
    counter =
        (ac - 2) / ((x->x_dimension * x->x_dimension * 2) + x->x_dimension);
  if (x->x_dimension == 2)
    counter = (ac - 2) / ((x->x_dimension * x->x_dimension) + x->x_dimension);
  x->x_lsset_amount = counter;

  if (counter <= 0) {
    post("vbapcart: Error in loudspeaker data!", 0);
    x->x_lsset_available = 0;
    return;
  }

  post("vbapcart: %d loudspeakers found", x->x_ls_amount);
  /*if (x->x_ls_amount > 55)
  {
          post("vbapcart: Too many!",0);
          x->x_lsset_available=0;
          return;
  }*/

  while (counter-- > 0) {
    for (i = 0; i < x->x_dimension; i++) {
      if (av[datapointer].a_type == A_FLOAT) {
        x->x_lsset[setpointer][i] = (long)av[datapointer++].a_w.w_float;
        /* 				post("%d",deb++); */
      } else {
        post("vbapcart: Error in loudspeaker data!", 0);
        x->x_lsset_available = 0;
        return;
      }
    }

    for (i = 0; i < x->x_dimension * x->x_dimension; i++) {
      if (av[datapointer].a_type == A_FLOAT) {
        x->x_set_inv_matx[setpointer][i] = av[datapointer++].a_w.w_float;
        /* 				post("%d",deb++); */
      } else {
        post("vbapcart: Error in loudspeaker data!", 0);
        x->x_lsset_available = 0;
        return;
      }
    }
    if (x->x_dimension == 3) {
      for (i = 0; i < x->x_dimension * x->x_dimension; i++) {
        if (av[datapointer].a_type == A_FLOAT) {
          x->x_set_matx[setpointer][i] = av[datapointer++].a_w.w_float;
          /* 					post("%d",deb++); */
        } else {
          post("vbapcart: Error in loudspeaker data!", 0);
          x->x_lsset_available = 0;
          return;
        }
      }
    }

    setpointer++;
  }
  post("vbapcart: Loudspeaker setup configured!", 0);
}

void vbapcart_in1(t_vbapcart *x,
                  long n) /* x = the instance of the object, n = the int
                             received in the right inlet */
/* panning X (cartesian) */
{
  x->x_x = n; /* store n in a global variable */
}

void vbapcart_in2(t_vbapcart *x,
                  long n) /* x = the instance of the object, n = the int
                             received in the right inlet */
/* panning Y (cartesian) */
{
  x->x_y = n; /* store n in a global variable */
}
/*--------------------------------------------------------------------------*/

void vbapcart_in3(t_vbapcart *x,
                  long n) /* x = the instance of the object, n = the int
                             received in the right inlet */
/* panning Z (cartesian) */
{
  if (n < 0)
    n = 0;
  x->x_z = n; /* store n in a global variable */
}

void vbapcart_in4(t_vbapcart *x,
                  long n) /* x = the instance of the object, n = the int
                             received in the right inlet */
/* spread amount */
{
  if (n < 0)
    n = 0;
  if (n > 100)
    n = 100;
  x->x_spread = n; /* store n in a global variable */
}

static void *vbapcart_new(t_symbol *s, int ac, t_atom *av)
/* create new instance of object... MUST send it an int even if you do nothing
   with this int!! */
{
  t_vbapcart *x;
  x = (t_vbapcart *)pd_new(vbapcart_class);

  /* pure data: */

  floatinlet_new(&x->x_ob, &x->x_x);
  floatinlet_new(&x->x_ob, &x->x_y);
  floatinlet_new(&x->x_ob, &x->x_z);
  floatinlet_new(&x->x_ob, &x->x_spread);

  x->x_outlet0 = outlet_new(&x->x_ob, gensym("list"));
  x->x_outlet1 = outlet_new(&x->x_ob, gensym("float"));
  x->x_outlet2 = outlet_new(&x->x_ob, gensym("float"));
  x->x_outlet3 = outlet_new(&x->x_ob, gensym("float"));
  x->x_outlet4 = outlet_new(&x->x_ob, gensym("float"));

  /* - */

  x->x_x = 1.0; /* default: front direction */
  x->x_y = 0.0;
  x->x_z = 0.0;
  x->x_spread_base[0] = 0.0;
  x->x_spread_base[1] = 1.0;
  x->x_spread_base[2] = 0.0;
  x->x_spread = 0;
  x->x_lsset_available = 0;
  if (ac > 0) {
    if (av[0].a_type == A_FLOAT)
      x->x_x = av[0].a_w.w_float;
  }
  if (ac > 1) {
    if (av[1].a_type == A_FLOAT)
      x->x_y = av[1].a_w.w_float;
  }
  if (ac > 2) {
    if (av[2].a_type == A_FLOAT)
      x->x_z = av[2].a_w.w_float;
  }
  return (x); /* return a reference to the object instance */
}
