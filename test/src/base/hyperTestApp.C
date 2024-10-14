//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "hyperTestApp.h"
#include "hyperApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
hyperTestApp::validParams()
{
  InputParameters params = hyperApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

hyperTestApp::hyperTestApp(InputParameters parameters) : MooseApp(parameters)
{
  hyperTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

hyperTestApp::~hyperTestApp() {}

void
hyperTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  hyperApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"hyperTestApp"});
    Registry::registerActionsTo(af, {"hyperTestApp"});
  }
}

void
hyperTestApp::registerApps()
{
  registerApp(hyperApp);
  registerApp(hyperTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
hyperTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  hyperTestApp::registerAll(f, af, s);
}
extern "C" void
hyperTestApp__registerApps()
{
  hyperTestApp::registerApps();
}
