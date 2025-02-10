//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "is_hypreTestApp.h"
#include "is_hypreApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
is_hypreTestApp::validParams()
{
  InputParameters params = is_hypreApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

is_hypreTestApp::is_hypreTestApp(InputParameters parameters) : MooseApp(parameters)
{
  is_hypreTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

is_hypreTestApp::~is_hypreTestApp() {}

void
is_hypreTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  is_hypreApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"is_hypreTestApp"});
    Registry::registerActionsTo(af, {"is_hypreTestApp"});
  }
}

void
is_hypreTestApp::registerApps()
{
  registerApp(is_hypreApp);
  registerApp(is_hypreTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
is_hypreTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  is_hypreTestApp::registerAll(f, af, s);
}
extern "C" void
is_hypreTestApp__registerApps()
{
  is_hypreTestApp::registerApps();
}
