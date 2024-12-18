penalty = 1e5
constraint_penalty = 1e6

ccz_blocks = "7 8 9 10 11 12 13 14"
nickel_blocks = "3 4 5 6"
steel_blocks = "1 2 15"

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  thermal_expansion_function_reference_temperature = 293.15
  stress_free_temperature = 293.15
[]

[Mesh]
  [meshy]
    type = FileMeshGenerator
    file = '../../mesh/case_0/case_0_contact.cpa.gz'
    skip_partitioning = True
  []
  [fo]
    type = ElementOrderConversionGenerator
    input = meshy
    conversion_type = FIRST_ORDER
  []
  construct_side_list_from_node_list=true
  patch_update_strategy = auto
[] 
  
[Variables]
  [temperature]
    family = LAGRANGE
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
  []
[]


[ICs]
  [disp_x]
    type = ConstantIC
    variable = disp_x
    value = 0.0000 # m
  []
  [disp_y]
    type = ConstantIC
    variable = disp_y
    value = 0.0000  # m
  [] 
  [disp_z]
    type = ConstantIC
    variable = disp_z
    value = 0.0000  # m
  []
[]

  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = HeatConduction 
    variable = temperature
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
    use_displaced_mesh = False
  []
  [dTdt]
    type = HeatConductionTimeDerivative
    variable = temperature
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
    use_displaced_mesh = False
  []
[]

[Modules/TensorMechanics/Master]
  [ccz_nickel]
    use_automatic_differentiation = false
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    #generate_output = 'vonmises_stress'
    eigenstrain_names = 'eigenstrain'
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
  []
  [steel_and_pins]
    use_automatic_differentiation = false
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    #generate_output = 'vonmises_stress'
    block = '1 2 15'
  []
[]
  
[UserObjects]
  [heat_flux_csv]
     type = PropertyReadFile
     prop_file_name = ../../HeatFlux/Case_0_rotated_HeatFlux.csv
     read_type = 'voronoi'
     nprop = 4
     nvoronoi = 5682
  []
[]

# Functions to control variable material parameters
[Functions]
  [htc_function]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../../HeatFlux/HTC.csv
    format = columns
  []  
  #Gaussian Heat profile
  [heat_profile]
    type = PiecewiseConstantFromCSV
    read_type = voronoi
    read_prop_user_object = heat_flux_csv
    column_number = 3
  []

  [./pressure_constant]
    type = ConstantFunction
    value = 0.7e6 # 0.7 MPa
  [../]
  
  [./cucrzr_rho_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/density.csv'
    format = columns
  [../]

  # Copper Youngs modulus
  [./cucrzr_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/youngs_modulus.csv'
    format = columns
  [../]
  
  #Copper Thermal conductivity
  [./cucrzr_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_conductivity.csv'
    format = columns
  [../]

  #Copper Thermal expansion
  [./cucrzr_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_expansion.csv'
    format = columns
  [../]

  # Copper specific heat
  [./cucrzr_sh_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/specific_heat.csv'
    format = columns
  [../]

  #Nickel youngs modulus
  [./nickel_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/youngs_modulus.csv'
    format = columns
  [../]
  
  #Nickel thermal conductivity
  [./nickel_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_conductivity.csv'
    format = columns
  [../]

  #Nickel thermal expansion
  [nickel_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_expansion.csv'
    format = columns
  []
[]

  
[Materials]
  [CCZ_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = 'temperature'
    youngs_modulus= 'ccz_ym'
    poissons_ratio = 0.33
    block = ${ccz_blocks}
  []

  [CCZ_heat]
    type = HeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = cucrzr_sh_fn
    thermal_conductivity_temperature_function = cucrzr_tc_fn
    block = ${ccz_blocks}
  []

  [CCZ_ym]
    type = PiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'ccz_ym'
    x = '2.000E+01 1.000E+02 1.500E+02 2.000E+02 2.500E+02 3.000E+02 3.500E+02 4.000E+02 4.500E+02 5.000E+02 6.000E+02 7.000E+02'
    y = '1.275E+11 1.270E+11 1.250E+11 1.230E+11 1.210E+11 1.180E+11 1.160E+11 1.130E+11 1.100E+11 1.060E+11 9.500E+10 8.600E+10'
    block = ${ccz_blocks}
  []

  [CCZ_density]
    type = PiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'density'
    x = '0 50 100 150 200 250 300 350 400 450 500'
    y = '8900 8886 8863 8840 8816 8791 8767 8742 8716 8691 8665'
    
    block = ${ccz_blocks}
  []

  [CCZ_thermal_expansion]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cucrzr_te_fn
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = ${ccz_blocks}
  []

  [nickel_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    youngs_modulus = 'nickel_ym'
    poissons_ratio = 0.31
    args = 'temperature'
    block = ${nickel_blocks}
  []

  [nickel_ym]
    type = PiecewiseLinearInterpolationMaterial
    property = 'nickel_ym'
    variable = temperature
    x = '-75 25 100 150 200 300 400 500 600 700'
    y = '2.13E+11 2.07E+11 2.02E+11 1.99E+11 1.97E+11 1.91E+11 1.86E+11 1.8E+11 1.76E+11 1.64E+11'
    block = ${nickel_blocks}
  []
  
  [nickel_heat]
    type = HeatConductionMaterial
    temp = temperature
    specific_heat = 456
    thermal_conductivity_temperature_function = nickel_tc_fn
    block = ${nickel_blocks}
  []

  [nickel_density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '8885'
    block = ${nickel_blocks}
  []

  [nickel_thermal_expansion]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = nickel_te_fn
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = ${nickel_blocks}
  []

  [steel]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '7850'
    block = ${steel_blocks}
  []

  [steel_elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
    block = ${steel_blocks}
  []

  [stress]
    type = ComputeLinearElasticStress
  []
[]


[BCs]
  [heat_flux]
    type = FunctionNeumannBC
    variable = temperature
    boundary = NS.BEAM_RECEIPT_FACE
    function = heat_profile
  []
 
  [heat_removal_backplate]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = 'NS.BACKPLATE_WETTED'
    heat_transfer_coefficient = 24200
    T_infinity = 295.15
  [../]

  [heat_removal_fins]
    type = ConvectiveFluxFunction
    variable = temperature
    boundary = 'NS.BASE_WETTED'
    coefficient = htc_function
    T_infinity = 295.15
  [../]

  [Pressure]
    [bc]
      boundary = 'NS.BASE_WETTED NS.BACKPLATE_WETTED NS.PIPES_WETTED'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    []
  []

  [disp_x_pins]
    type = DirichletBC
    variable = disp_x
    boundary = SS.PIN_DIR
    value = 0
  []
  [disp_y_pins]
    type = DirichletBC
    variable = disp_y
    boundary = SS.PIN_DIR
    value = 0
  []
  [disp_z_pins]
    type = DirichletBC
    variable = disp_z
    boundary = SS.PIN_DIR
    value = 0
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 1.5
  dt = 0.1
  #steady_state_tolerance = 1e-6
  #steady_state_detection = true
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = NEWTON

  nl_rel_tol = 1e-15
  nl_abs_tol = 5e-8
  l_tol = 1e-8
  l_abs_tol = 1e-12
  l_max_its = 100
  line_search = none
[]

[Constraints]
    [rbe3_x_hole]
        type = RBEConstraint
        primary_node_set_id = 10
        secondary_node_set_id = 13
        variable = disp_x
        primary_size = ${pih_size}
        penalty = ${constraint_penalty}
    []
[]

[Contact]
  [hole]
    primary = SS.HOLE_CONTACT
    secondary = NS.PIN_HOLE_CONTACT
    model = coulomb
    penalty = ${penalty}
    friction_coefficient = 0.64
    formulation = penalty
    normal_smoothing_distance = 0.1
  []
  
  [slot]
    primary = SS.SLOT_CONTACT
    secondary = NS.PIN_SLOT_CONTACT
    model = coulomb
    penalty = ${penalty}
    friction_coefficient = 0.64
    formulation = penalty
    normal_smoothing_distance = 0.1
  []
[]

[Preconditioning]
  [FSP]
    type = FSP
    topsplit = 'contact_split'
    [contact_split]
      splitting = 'interior contact temperature'
      splitting_type = additive
      #petsc_options = '-snes_ksp_ew'
      petsc_options_iname = '-ksp_gmres_restart -mat_mffd_err'
      petsc_options_value = '200  1e-5'
      #schur_pre = 'Sp'
    []
    [interior]
      type = ContactSplit
      vars = 'disp_x disp_y disp_z'
      uncontact_primary = 'SS.HOLE_CONTACT SS.SLOT_CONTACT'
      uncontact_secondary = 'NS.PIN_HOLE_CONTACT NS.SLOT_HOLE_CONTACT'
      uncontact_displaced = '1 1'
      petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type'
      petsc_options_value = 'preonly hypre boomeramg 301 0.4 ext+i PMIS'
      include_all_contact_nodes = 1
     
    []
    [contact]
      type = ContactSplit
      vars = 'disp_x disp_y disp_z'
      contact_primary = 'SS.HOLE_CONTACT SS.SLOT_CONTACT'
      contact_secondary = 'NS.PIN_HOLE_CONTACT NS.SLOT_HOLE_CONTACT'
      contact_displaced = '1 1'
      include_all_contact_nodes = 1
      petsc_options_iname = '-ksp_type -pc_type -pc_asm_overlap -sub_pc_type'
      petsc_options_value = 'preonly   asm      1               ilu'
    []
    [temperature]
      vars = 'temperature'
      petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
      petsc_options_value = 'preonly hypre boomeramg 301 0.4 ext+i PMIS 4 2 0.4'
    []
  []
[]

[Outputs]
  exodus = true
#  nemesis = true
  perf_graph = true
[]

[Debug]
  show_var_residual_norms = true
[]
